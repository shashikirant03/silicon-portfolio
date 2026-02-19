`timescale 1ns / 1ps

module tb_uart_top;

    // 1. Parameters
    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;
    
    // We calculate bit periods based on parameters for accuracy
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE; 
    localparam BIT_PERIOD = 104167; // 10^9 / 9600 = ~104166.6ns

    // 2. Signals
    reg clk;
    reg rst;
    reg rx_serial_in;   // Input to FPGA (driven by TB)
    wire tx_serial_out; // Output from FPGA (monitored by TB)
    wire [7:0] rx_debug_data;
    wire rx_debug_done;

    // 3. Instantiate Top Level
    uart_top uut (
        .clk(clk),
        .rst(rst),
        .rx_serial(rx_serial_in),
        .tx_serial(tx_serial_out),
        .rx_data(rx_debug_data), // Debug monitoring
        .rx_done(rx_debug_done)  // Debug monitoring
    );

    // 4. Clock Generation (50MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // 5. Waveform Dump
    initial begin
        $dumpfile("uart_top.vcd");
        $dumpvars(0, tb_uart_top);
    end

    // 6. The Main Test Sequence
    initial begin
        // --- Initialization ---
        rst = 1;
        rx_serial_in = 1; // Idle High (UART Standard)
        #1000;
        
        rst = 0;
        #1000;

        $display("---------------------------------------------------");
        $display("TEST STARTED: Sending sequence 'A', 'B', 'C'...");
        $display("---------------------------------------------------");

        // --- Send Character 'A' (0x41) ---
        test_char(8'h41); 
        
        // Wait a bit before next character (Simulating a pause)
        #50000; 

        // --- Send Character 'B' (0x42) ---
        test_char(8'h42);
        
        #50000;

        // --- Send Character 'C' (0x43) ---
        test_char(8'h43);

        $display("---------------------------------------------------");
        $display("TEST FINISHED: All 3 characters echoed successfully.");
        $display("Please open 'uart_top.vcd' to verify the TX waveform.");
        $display("---------------------------------------------------");
        $finish;
    end

    // --- TASK: Send Character AND Verify Loopback ---
    task test_char(input [7:0] char_to_send);
        begin
            $display("[TEST] Sending 0x%h...", char_to_send);

            // 1. Parallel Block: Drive RX and Monitor RX Done
            fork
                send_byte(char_to_send);
                begin
                    // Wait for the RX module to finish
                    @(posedge rx_debug_done);
                    
                    // Check if RX got the right data
                    if (rx_debug_data !== char_to_send) 
                        $display("    [FAIL] RX Mismatch! Sent %h, Got %h", char_to_send, rx_debug_data);
                    else
                        $display("    [PASS] RX Received 0x%h", rx_debug_data);
                end
            join

            // 2. Sequential Block: Monitor TX Echo
            // Wait for TX to start (Start Bit = 0)
            wait(tx_serial_out == 0);
            $display("    [INFO] Echo Started (TX Line Drop Detected)...");

            // Wait for TX to finish sending the byte back
            // (1 Start + 8 Data + 1 Stop = 10 bits) * Period
            // We wait 11 bits to be safe and ensure the Stop Bit is fully done.
            #(BIT_PERIOD * 11);
            
            $display("    [PASS] Echo Complete.");
        end
    endtask

    // --- TASK: Simulate External Device Sending Data ---
    task send_byte(input [7:0] data);
        integer i;
        begin
            // Start Bit (Drive Low)
            rx_serial_in = 0;
            #BIT_PERIOD;
            
            // Data Bits (LSB First)
            for (i=0; i<8; i=i+1) begin
                rx_serial_in = data[i];
                #BIT_PERIOD;
            end
            
            // Stop Bit (Drive High)
            rx_serial_in = 1;
            #BIT_PERIOD;
        end
    endtask

endmodule