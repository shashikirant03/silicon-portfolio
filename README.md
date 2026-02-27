# Silicon Design Portfolio 

A collection of Digital VLSI projects moving from **RTL Design** to **GDSII Silicon Layout** using Open-Source EDA tools.

## Toolchain
- **Simulation**: Icarus Verilog, GTKWave
- **Linting**: Verilator
- **Formal Verification**: SymbiYosys (SBY)
- **Synthesis**: Yosys
- **Physical Design**: OpenLane (Sky130 PDK)

## Projects

### 1. [mux2to1](./mux2to1)

A foundational project used to establish and verify the complete open-source RTL-to-GDSII EDA toolchain.

### 2. [alu](./alu)

A combinational compute block supporting standard arithmetic and bitwise operations.

### 3. [counter4bit](./counter4bit)

A simple 4-bit synchronous counter project demonstrating basic sequential logic and simulation.

### 4. [UART Controller](./uart)

A fully verified UART (Universal Asynchronous Receiver-Transmitter) hardened for the SkyWater 130nm process.
- **Verification**: Mathematically proven reset states and interface stability using **Formal Verification (SBY)**.
- **Linting**: 100% clean under **Verilator -Wall**.
- **Physical Design**: Successfully routed with a 40% core utilization and 50MHz timing closure.

### 5. [CAN_Bus_Controller](./can_bus).

A cycle-accurate, multi-module CAN node demonstrating distributed network arbitration and high-density physical design.
- **Verification**: Distributed multi-node testbench proving lossless bitwise arbitration (CSMA/CD+AMP).
- **Linting**: 100% clean under Verilator -Wall.
- **Physical Design**: Successfully routed 1,535 logic cells with a 0.55 target density and 20ns timing closure.
