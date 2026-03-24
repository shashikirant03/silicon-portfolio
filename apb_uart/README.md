**APB UART Peripheral: RTL-to-GDSII Physical Design**

*Project Overview*

This project involves the design, verification, and physical implementation of a Universal Asynchronous Receiver-Transmitter (UART) peripheral integrated with an AMBA 3 APB (Advanced Peripheral Bus) interface. The design is optimized for the SkyWater 130nm Open-Source PDK.

The integration of the APB bridge transforms a standalone serial engine into a memory-mapped IP block. This allows a high-speed processor (Master) to control the UART via standardized read/write operations, abstracting the bit-level timing from the software layer.

*Technical Specifications*

    Bus Interface: AMBA 3 APB (PSEL, PENABLE, PWRITE, PADDR, PWDATA, PRDATA, PREADY).

    UART Protocol: 8-bit data, 1 start bit, 1 stop bit, programmable baud rate.

    Clock Domain: 100MHz (10ns period) synchronous PCLK.

    Process Node: SkyWater 130nm (sky130_fd_sc_hd).

*Repository Structure*

    apb_uart.v: Top-level module integrating the APB Slave interface with the UART core.

    uart_tx.v / uart_rx.v: Independent transmit and receive serial engines.

    tb_apb_uart.v: Testbench for functional verification and loopback testing.

    apb_uart.sby: Formal verification configuration for protocol compliance.

    config.json: Physical design constraints for the OpenLane flow.

*Implementation Flow*

1. Functional & Formal Verification

The design was validated using a dual-verification strategy:

    Simulation: Icarus Verilog was used to confirm data integrity during parallel-to-serial conversion.

    Formal Proofs: SymbiYosys was utilized to mathematically prove that the APB state machine never reaches an invalid state, ensuring 100% reliability under all bus sequences.

2. Physical Design (OpenLane)

The RTL was "hardened" into a GDSII layout. To achieve a manufacturable design, the following constraints were applied:

    Die Area: 200µm x 200µm.

    Target Density: 40% (to ensure routability).

    Antenna Protection: Enabled heuristic diode insertion to prevent transistor gate damage during plasma etching.


*Final Sign-off Results*

The design achieved a "Tape-out Ready" status with the following metrics:

    Magic DRC: 0 Violations.

    LVS Status: Design is LVS clean (573 nets matched).

    Antenna Summary: 0 Pin violations.
