`timescale 1ns / 1ps

module tb_can_bsp();

    // 1. Declare Signals directly matching your module
    reg clk;
    reg rst;
    reg sample_point;
    reg tx_point;
    reg rx_in;
    wire tx_out;
    reg tx_data_in;
    reg enable_stuffing;
    wire rx_data_out;
    wire tx_stall;
    wire rx_stall;
    wire stuff_err;

    // 2. Instantiate your BSP
    // Update the UUT instantiation in your testbench
    can_bsp uut (
        .clk(clk),
        .rst(rst),
        .sample_point(sample_point),
        .tx_point(tx_point),
        .rx_in(rx_in),
        .tx_data_in(tx_data_in),
        .enable_tx_stuffing(enable_stuffing), // Map your old test signal to the new TX port
        .enable_rx_stuffing(enable_stuffing), // Map it to RX too
        .tx_out(tx_out),
        .rx_data_out(rx_data_out),
        .tx_stall(tx_stall),
        .rx_stall(rx_stall)
    );

    // 3. System Clock
    always #10 clk = ~clk;

    // 4. Metronome Timer (Generates sample and tx points)
    integer tq = 0;
    always @(posedge clk) begin
        if (rst) begin
            tq <= 0;
            sample_point <= 0;
            tx_point <= 0;
        end else begin
            sample_point <= 0;
            tx_point <= 0;
            tq <= tq + 1;
            
            if (tq == 10) sample_point <= 1'b1;
            if (tq == 14) begin
                tx_point <= 1'b1;
                tq <= 0;
            end
        end
    end

    // 5. Linear Test Sequence
    initial begin
        $dumpfile("can_bsp_wave.vcd");
        $dumpvars(0, tb_can_bsp);

        // --- BOOT UP ---
        clk = 0;
        rst = 1;
        rx_in = 1;
        tx_data_in = 1;
        enable_stuffing = 0;
        
        #50 rst = 0;
        @(posedge tx_point); 
        
        // ==========================================
        // TEST 1: TX STUFFING
        // ==========================================
        enable_stuffing = 1;
        tx_data_in = 0; // We want to send pure zeros
        
        // We manually alternate rx_in here just to prevent RX errors from firing
        rx_in = 1; @(posedge tx_point); // Bit 1
        rx_in = 0; @(posedge tx_point); // Bit 2
        rx_in = 1; @(posedge tx_point); // Bit 3
        rx_in = 0; @(posedge tx_point); // Bit 4
        rx_in = 1; @(posedge tx_point); // Bit 5 (Module sees 5 zeros, triggers stall!)
        
        rx_in = 0; @(posedge tx_point); // Stall cycle (Module injects a '1' on tx_out)
        
        rx_in = 1; @(posedge tx_point); // Bit 6 (Finally gets to send the 6th zero)

        // ==========================================
        // TEST 2: RX DESTUFFING
        // ==========================================
        // Keep TX quiet for this test
        tx_data_in = 1; 

        // Start of Frame (Bus drops to 0)
        rx_in = 0; @(posedge sample_point);
        
        // Bus sends five '1's in a row
        rx_in = 1; @(posedge sample_point); // Bit 1
        rx_in = 1; @(posedge sample_point); // Bit 2
        rx_in = 1; @(posedge sample_point); // Bit 3
        rx_in = 1; @(posedge sample_point); // Bit 4
        rx_in = 1; @(posedge sample_point); // Bit 5
        
        // Stuff bit arrives (Module sees a '0' and triggers rx_stall)
        rx_in = 0; @(posedge sample_point); 
        
        // Normal data resumes
        rx_in = 1; @(posedge sample_point); 

        // Finish up
        #1000;
        $finish;
    end

endmodule