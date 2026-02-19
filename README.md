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
**Level: Introductory (Combinational)**
The "Hello World" of Digital VLSI—focusing on the foundational OpenLane flow for combinational logic.

### 2. [counter4bit](./counter4bit)
**Level: Basic (Sequential)**
A simple 4-bit synchronous counter project demonstrating basic sequential logic and simulation.

### 3. [UART Controller: RTL to GDSII](./uart)
**Level: Intermediate (System Peripheral)**
A fully verified UART (Universal Asynchronous Receiver-Transmitter) hardened for the SkyWater 130nm process.
- **Verification**: Mathematically proven reset states and interface stability using **Formal Verification (SBY)**.
- **Linting**: 100% clean under **Verilator -Wall**.
- **Physical Design**: Successfully routed with a 40% core utilization and 50MHz timing closure.
