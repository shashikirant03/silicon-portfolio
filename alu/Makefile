# Project variables
PROJ = alu
SRC  = $(PROJ).v
TB   = tb_$(PROJ).v

# Default target: Run everything
all: lint sim formal

# 1. Linting (Checks for errors)
lint:
	verilator --lint-only -Wall $(SRC)

# 2. Simulation (Icarus Verilog)
sim:
	iverilog -o sim.vvp $(SRC) $(TB)
	vvp sim.vvp
	gtkwave simulation.vcd &

# 3. Formal Verification (SymbiYosys)
formal:
	sby -f formal.sby

# Cleanup
clean:
	rm -rf sim.vvp simulation.vcd formal/