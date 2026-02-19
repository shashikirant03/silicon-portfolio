`timescale 1ns / 1ps

module tb_uart_rx;

    // 1. Parameters
    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;
    // Calculation: 50,000,000 / 9600 = 5208 clocks per bit
    parameter CLKS_PER_BIT = 5208; 
    parameter BIT_PERIOD = 104160; // 5208 * 20ns

    // 2. Signals
    reg clk;
    reg rst;
    reg rx_serial;
    wire rx_active;
    wire [7:0] rx_data;
    wire rx_done;

    // 3. Instantiate the Receiver (UUT)
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk(clk),
        .rst(rst),
        .rx_serial(rx_serial),
        .rx_active(rx_active),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // 4. Clock Generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // 5. Waveform Generation
    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);
    end

    // 6. Test Sequence
    initial begin
        // Init
        rst = 1;
        rx_serial = 1; // Idle High
        #1000;
        
        rst = 0;
        #1000;

        // --- TEST: Send 0xA5 ---
        $display("TEST STARTED: Sending 0xA5...");
        
        // Call the task defined BELOW (not inside) this block
        send_byte(8'hA5);

        // Wait for receiver to finish
        #50000; 

        if (rx_data === 8'hA5)
            $display("TEST PASSED: Received 0xA5");
        else
            $display("TEST FAILED: Received 0x%h", rx_data);

        $finish;
    end

    // 7. Task Definition (MUST BE OUTSIDE INITIAL BLOCK)
    task send_byte;
        input [7:0] data;
        integer i;
        begin
            // Start Bit (Low)
            rx_serial = 0;
            #BIT_PERIOD;

            // Data Bits (LSB First)
            for (i=0; i<8; i=i+1) begin
                rx_serial = data[i];
                #BIT_PERIOD;
            end

            // Stop Bit (High)
            rx_serial = 1;
            #BIT_PERIOD;
        end
    endtask

endmodule