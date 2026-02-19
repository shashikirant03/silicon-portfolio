`timescale 1ns / 1ps

module tb_uart_tx;

    // 1. Signals
    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx_active;
    wire tx_serial;
    wire tx_done;

    // 2. Instantiate the Unit Under Test (UUT)
    uart_tx #(
        .CLK_FREQ(50000000),  // 50 MHz
        .BAUD_RATE(9600)      // 9600 Baud
    ) uut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_active(tx_active),
        .tx_serial(tx_serial),
        .tx_done(tx_done)
    );

    // 3. Clock Generation (50 MHz = 20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // 4. VCD Dump for Waveforms
    initial begin
        $dumpfile("uart_tx.vcd");  // Fixed missing semicolon
        $dumpvars(0, tb_uart_tx);
    end

    // 5. Test Sequence
    initial begin
        // Initialize Inputs
        rst = 1;
        tx_start = 0;
        tx_data = 8'h00;

        // Reset Sequence
        #100;
        rst = 0;
        #100;

        // --- TEST CASE 1: Send 'A' (0x41) ---
        $display("TEST STARTED: Sending 'A' (0x41)...");
        
        // Synchronize with clock edge for safety
        @(posedge clk); 
        tx_data = 8'h41;  // Binary: 01000001
        tx_start = 1;     // Trigger Start
        
        @(posedge clk); 
        tx_start = 0;     // Release Trigger (Pulse)

        // Wait for the 'Done' signal
        wait(tx_done);
        
        $display("TEST PASSED: 'A' transmitted successfully.");

        // Wait a bit to see the line go Idle (High)
        #1000;
        $finish;
    end

endmodule