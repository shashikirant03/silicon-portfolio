`timescale 1ns / 1ps

module tb_can_btl();

    // 1. Declare Testbench Signals
    reg  clk;
    reg  rst;
    reg  rx_sync_edge;
    wire sample_point;
    wire tx_point;

    // 2. Instantiate the Bit Timing Logic (The Device Under Test)
    can_btl #(
        .BRP(4),
        .TSEG1(11),
        .TSEG2(4)
    ) uut (
        .clk(clk),
        .rst(rst),
        .rx_sync_edge(rx_sync_edge),
        .sample_point(sample_point),
        .tx_point(tx_point)
    );

    // 3. Generate the 50 MHz System Clock (20ns period)
    always #10 clk = ~clk; 

    // 4. Test Sequence
    initial begin
        // Setup GTKWave Output File
        $dumpfile("can_btl_wave.vcd");
        $dumpvars(0, tb_can_btl);

        // A. Boot Up
        $display("--- Starting CAN BTL Simulation ---");
        clk = 0;
        rst = 1;
        rx_sync_edge = 0;
        
        // Wait 50ns, then release reset
        #50 rst = 0;
        $display("Time: %0t | Reset released. Normal operation begins.", $time);

        // B. Wait and watch a few full CAN bits generate normally
        // 1 Bit = 15 TQs. 1 TQ = 4 clocks (80ns). 1 Bit = 1200ns.
        #3000; 

        // C. Fire the Hard Sync Interrupt (Simulate bus activity)
        $display("Time: %0t | Firing rx_sync_edge (Hard Sync)!", $time);
        @(posedge clk);
        rx_sync_edge = 1'b1; // Pulse high for exactly 1 clock cycle
        @(posedge clk);
        rx_sync_edge = 1'b0;

        // D. Watch it recover and generate another bit
        #2000;

        // E. End Simulation
        $display("--- Simulation Complete ---");
        $finish;
    end

endmodule