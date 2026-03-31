# Simple Makefile for RV32I
SRCS = alu.v register_file.v control_unit.v program_counter.v instruction_memory.v data_memory.v rv32i_core.v
TB = tb_top.v

sim:
	iverilog -o cpu.vvp $(SRCS) $(TB)
	vvp cpu.vvp

clean:
	rm -f *.vvp *.vcd

gcc:
	# 1. Compile C to a RISC-V ELF file
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding -O1 -Wl,-Ttext=0x0 -o main.elf main.c
	
	# 2. Extract the raw machine code binary
	riscv64-unknown-elf-objcopy -O binary main.elf main.bin
	
	# 3. Format the binary into a 32-bit Hex text file for Verilog
	hexdump -v -e '1/4 "%08x\n"' main.bin > program.hex