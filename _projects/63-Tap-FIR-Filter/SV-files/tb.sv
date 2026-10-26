`timescale 1ns/1ps

module tb;
    localparam int DW = 32;
    localparam int AW = 32;
    localparam int OW = 20;

    localparam logic [1:0] HTRANS_IDLE   = 2'b00;
    localparam logic [1:0] HTRANS_NONSEQ = 2'b10;

    logic        HCLK;
    logic        HRESETn;

    logic [AW-1:0] HADDR;
    logic [1:0]    HTRANS;
    logic          HWRITE;
    logic [2:0]    HSIZE;
    logic [DW-1:0] HWDATA;
    logic          HSEL;
    logic          HREADY;

    logic [DW-1:0] HRDATA;
    logic          HREADYOUT;
    logic          HRESP;

    ahb_s_intf #(.DW(DW), .AW(AW)) ahb_if();

    assign ahb_if.HADDR     = HADDR;
    assign ahb_if.HTRANS    = HTRANS;
    assign ahb_if.HWRITE    = HWRITE;
    assign ahb_if.HSIZE     = HSIZE;
    assign ahb_if.HWDATA    = HWDATA;
    assign ahb_if.HSEL      = HSEL;
    assign ahb_if.HREADY    = HREADY;
    assign HRDATA           = ahb_if.HRDATA;
    assign HREADYOUT        = ahb_if.HREADYOUT;
    assign HRESP            = ahb_if.HRESP;

    assign HREADY = HREADYOUT;


    logic [9:0] coeff_mem [0:31];
    logic [9:0] in_signal [255:0];
    logic [1:0] status;
    logic IRQ;
    logic [19:0] read_mem [255:0];

    // AHB Wrapper instance
    //TODO ADD YOUR ACCEL INSTANCE HERE!
	ACCEL dut (
		.ACCEL_CLK(HCLK),
		.ACCEL_RSTN(HRESETn),
		.IRQ(IRQ),
		.S(ahb_if.sink)
	);

    // Clock generation
    initial begin
        HCLK = 1'b0;
        forever #10 HCLK = ~HCLK;
    end

    // Simulation timeout
    initial begin
        $timeformat(-9, 5, " ns", 10);
        #10000000;
        $display("Timeout reached");
        $finish;
    end

    task ahb_init();
        HADDR  = '0;
        HTRANS = HTRANS_IDLE;
        HWRITE = 1'b0;
        HSIZE  = 3'b010;  // 32-bit
        HWDATA = '0;
        HSEL   = 1'b0;
    endtask

    task ahb_write(input logic [AW-1:0] addr, input logic [DW-1:0] data);
        @(posedge HCLK);
        HSEL   <= 1'b1;
        HTRANS <= HTRANS_NONSEQ;
        HWRITE <= 1'b1;
        HADDR  <= addr;

        @(posedge HCLK);
        HWDATA <= data;
        HTRANS <= HTRANS_IDLE;
        HSEL   <= 1'b0;

        @(posedge HCLK);
    endtask

    task ahb_read(input logic [AW-1:0] addr, output logic [DW-1:0] data);
        @(posedge HCLK);
        HSEL   <= 1'b1;
        HTRANS <= HTRANS_NONSEQ;
        HWRITE <= 1'b0;
        HADDR  <= addr;

        @(posedge HCLK);
        HTRANS <= HTRANS_IDLE;
        HSEL   <= 1'b0;

        @(posedge HCLK);
        data = HRDATA;
    endtask

    initial begin
        ahb_init();
        HRESETn = 1'b0;

        #500;
        HRESETn = 1'b1;
        #100;
	
	//TODO add ahb transaction tasks to perform the following operations. 
		
        // Load coefficients
	        
        $readmemb("filter_coefficient.tv", coeff_mem);
	$readmemb("signal_input.txt", in_signal);
	
	ahb_write(32'h00000010, 32'h2);
	
	for (int i = 0; i <  32; i++) begin
		ahb_write(32'h0000001C, coeff_mem[i]);
	end	
		
	// Set idle state
	ahb_write(32'h00000010, 32'h1);
	// Perform filtering
	ahb_write(32'h00000010, 32'h4);
	for (int i = 0; i < 256; i++) begin
		ahb_write(32'h00000018, in_signal[i]);
		@(posedge HCLK);
	end
	// Check for done 
	if (IRQ !== 1'b1) begin
		$display("ERROR: IRQ not asserted after 256 samples");
	end

	// Readout values
	ahb_write(32'h00000010, 32'h8);

	for (int i = 0; i < 256; i++) begin
		ahb_write(32'h00000020, i);
		ahb_read(32'h00000024, read_mem[i]);

		$display("Signal Sample: %d, Signal Value: %h", i, read_mem[i]);
	end


	// Set idle state
	ahb_write(32'h00000010, 32'h1);
	
    end
    initial begin
        $dumpfile("Lab4.vcd");
        $dumpvars();
    end
endmodule
