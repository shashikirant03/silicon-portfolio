# Simple Makefile for RV32I
SRCS = alu.v register_file.v control_unit.v program_counter.v instruction_memory.v data_memory.v rv32i_core.v
TB = tb_top.v

sim:
	iverilog -o cpu.vvp $(SRCS) $(TB)
	vvp cpu.vvp

clean:
	rm -f *.vvp *.vcd