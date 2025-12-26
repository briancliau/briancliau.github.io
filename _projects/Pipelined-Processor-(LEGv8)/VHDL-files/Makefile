GHDL=ghdl
VERS="--std=08"
FLAG="--ieee=synopsys"

# IMPORTANT: students, please do not change the names of the testbench files or
# entities here. instead, ensure that YOUR testbench files and entity names 
# match the ones here


.common: 
	@$(GHDL) -a $(VERS) mux5.vhd mux64.vhd pc.vhd shiftleft2.vhd signextend.vhd
# TODO: add your adder file names below (from lab2):
	@$(GHDL) -a $(VERS) add32.vhd add.vhd
	@$(GHDL) -a $(VERS) alu.vhd alucontrol.vhd cpucontrol.vhd dmem.vhd registers.vhd
# TODO: add any other helper files below:
	@$(GHDL) -a $(VERS) IDEXcpucontrol.vhd EXMEMcpucontrol.vhd register1.vhd register5.vhd register11.vhd register32.vhd register64.vhd 
	@$(GHDL) -a $(VERS) mux_3.vhd controlMUX.vhd hazarddetection.vhd forwardingUnit.vhd IFID_register32.vhd IFID_register64.vhd add_value.vhd

# TODO: you are free to add files below if that helps
# Do not add stop times. To stop simulations, consult pipecpu0_tv.vhd for information.
p1: 
	make .common
	@$(GHDL) -a $(VERS) imem_p1.vhd
	@$(GHDL) -a $(VERS) pipelinedcpu1.vhd pipecpu1_tb.vhd
	@$(GHDL) -e $(VERS) PipeCPU_testbench
	@$(GHDL) -r $(VERS) PipeCPU_testbench --wave=p1_wave.ghw

p2: 
	make .common
	@$(GHDL) -a $(VERS) imem_p2.vhd
	@$(GHDL) -a $(VERS) pipelinedcpu1.vhd pipecpu1_tb.vhd
	@$(GHDL) -e $(VERS) PipeCPU_testbench
	@$(GHDL) -r $(VERS) PipeCPU_testbench --wave=p2_wave.ghw

clean:
	rm *_sim.out *.cf *.ghw