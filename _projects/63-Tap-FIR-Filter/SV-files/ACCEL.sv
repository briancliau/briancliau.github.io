// ACCEL.sv

`default_nettype none
`include "rtl_macros.svh"


module ACCEL 
(
input  logic            ACCEL_CLK, ACCEL_RSTN,
output logic            IRQ,
ahb_s_intf.source   S
);


always_comb IRQ = 1'b0;

reg_intf      #(.DW(32),.AW(32)) pregs();

//---------------------------------------------------------
// AHB sub interface
//---------------------------------------------------------
// Main AHB bus sub interface (HCLK domain)


ahb_sub #(.DW(32), .AW(32)) u_accel
( 
.clk        (ACCEL_CLK),
.rstn       (ACCEL_RSTN),
.S          (S),
.regs      (pregs.source)
);


//---------------------------------------------------------
// pregs
//---------------------------------------------------------
// Control and Status registers (CSRs) in HCLK domain.
// These are generated automatically.

// Copy content of ./pregs/output/pregs.inst.sv here
// START
logic [3:0] CTRL;
logic [1:0] STATUS;
logic [9:0] IN_SAMPLE;
logic [9:0] IN_COEFF;
logic [7:0] OUT_SAMPLE_ADDR;
logic [19:0] OUT_SAMPLE;

pregs u_pregs (

// clocks and resets
.clk(ACCEL_CLK),
.rstn(ACCEL_RSTN),

// Synchronous register interface
.regbus           (pregs.sink),

// reg file signals
.CTRL(CTRL[3:0])	/* idx 4 */,
.STATUS(STATUS[1:0])	/* idx 5 */,
.IN_SAMPLE(IN_SAMPLE[9:0])	/* idx 6 */,
.IN_COEFF(IN_COEFF[9:0])	/* idx 7 */,
.OUT_SAMPLE_ADDR(OUT_SAMPLE_ADDR[7:0])	/* idx 8 */,
.OUT_SAMPLE(OUT_SAMPLE[19:0])	/* idx 9 */

);
// END

// Logic signals within ACCEL
logic [255:0][19:0] OUTPUT_BUFFER;
logic ACCEL_LOAD;
logic ACCEL_EN;
logic signed [9:0] FIR_ADDRESS_PTR;
logic signed [9:0] SIGNAL_INPUT;
logic signed [9:0] FILTER_COEFF;
logic signed [9:0] SIGNAL_OUTPUT;
logic IN_SAMPLE_WR;

assign STATUS[0] = (FIR_ADDRESS_PTR == 8'd255);
assign STATUS[1] = (CTRL == 4'h4);
assign OUT_SAMPLE = OUTPUT_BUFFER[OUT_SAMPLE_ADDR];
assign IQR = (FIR_ADDRESS_PTR == 8'd255);
assign IN_SAMPLE_WR = pregs.hwrite && preg.hsel && pregs.hreadyout && (pregs.haddr[9:2] == 8'd6);

// FIR filter
FIR_63TAP fir_filter (
.CLK(ACCEL_CLK),
.RSTN(ACCEL_RSTN && (CTRL != 4'h8)),
.LOAD(ACCEL_LOAD),
.in(SIGNAL_INPUT),
.filter_coeff(FILTER_COEFF),
.out(SIGNAL_OUTPUT),
.EN(ACCEL_EN)
);

always_comb begin
	ACCEL_LOAD = (CTRL == 4'h2);
	ACCEL_EN   = (CTRL == 4'h4);
end

always_ff @(posedge ACCEL_CLK or negedge ACCEL_RSTN) begin
	if (!ACCEL_RSTN) begin
		FIR_ADDRESS_PTR <= 0;
	end else begin
		if (CTRL == 4'h2) begin
			FILTER_COEFF <= IN_COEFF;
		end else if (CTRL == 4'h4 && IN_SAMPLE_WR) begin
			SIGNAL_INPUT <= IN_SAMPLE;
			OUTPUT_BUFFER[FIR_ADDRESS_PTR] <= SIGNAL_OUTPUT;
			FIR_ADDRESS_PTR <= FIR_ADDRESS_PTR + 1'b1;
		end else if (CTRL == 4'h8) begin
			FIR_ADDRESS_PTR <= 8'd0;
		end
	end
end
endmodule

`default_nettype wire

