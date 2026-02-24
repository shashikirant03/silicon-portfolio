# Makefile for CAN Bus Verification Environment

# Toolchain
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave

# Project Files
SOURCE = can_btl.v can_bsp.v can_crc.v can_fsm.v can_top.v tb_can_calc_network.v
OUTPUT = calc_sim
WAVEFORM = can_calc_wave.vcd

# Default target executes both compile and run
all: compile run

compile:
	$(COMPILER) -o $(OUTPUT) $(SOURCE)

run:
	$(SIMULATOR) $(OUTPUT)

wave:
	$(VIEWER) $(WAVEFORM) &

clean:
	rm -f $(OUTPUT) $(WAVEFORM)
