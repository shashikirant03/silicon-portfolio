# UART Controller: RTL to GDSII (Sky130)

A fully verified and hardened UART (Universal Asynchronous Receiver-Transmitter) controller. This project demonstrates a complete ASIC design flow—from Verilog RTL and mathematical formal proof to physical GDSII layout.

## Features
- **Independent Modules**: Separate RX and TX engines with a top-level loopback wrapper.
- **Configurable**: Parameterized clock frequency and baud rate.
- **Verified**: 100% lint-clean (Verilator) and mathematically proven (SymbiYosys).
- **Physical Design**: Hardened for SkyWater 130nm process using the OpenLane flow.

## Project Structure
- `uart_top.v`: Top-level loopback wrapper with Formal properties.
- `uart_tx.v` & `uart_rx.v`: The core UART engines.
- `formal.sby`: Configuration for SymbiYosys formal verification.
- `config.json`: Physical design constraints for OpenLane.
- `Makefile`: Unified build script for linting, simulation, and formal checks.

## Physical Design Specs
- **PDK**: SkyWater 130nm (sky130A)
- **Clock Period**: 20ns (50MHz)
- **Core Utilization**: 40% (Optimized for routing success)
- **Tool**: OpenLane / OpenROAD

## How to Run
1. **Linting**: `make lint`
2. **Simulation**: `make sim`
3. **Formal Verification**: `make formal`
