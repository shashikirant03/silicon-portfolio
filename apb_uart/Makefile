# Default target: Run everything
all: lint sim formal

# 1. Linting (Checks for errors)
lint:
	verilator --lint-only -Wall apb_uart.v

# 2. Simulation (Icarus Verilog)
sim:
	iverilog -o sim.vvp *.v
	vvp sim.vvp
	gtkwave apb_uart.vcd &

# 3. Formal Verification (SymbiYosys)
formal:
	sby -f apb_uart.sby

# Cleanup
clean:
	rm -rf sim.vvp apb_uart.vcd formal/