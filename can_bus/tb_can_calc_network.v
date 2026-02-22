`timescale 1ns / 1ps

module tb_can_calc_network();
    reg clk, rst; wire can_bus;
    reg tx_req_A, tx_req_B, tx_req_C;
    reg [10:0] tx_id_A, tx_id_B, tx_id_C;
    reg [63:0] tx_data_A, tx_data_B, tx_data_C;
    wire rx_val_A, rx_val_B, rx_val_C;
    wire [63:0] rx_data_A, rx_data_B, rx_data_C;
    wire [10:0] rx_id_A, rx_id_B, rx_id_C;
    wire tx_A, tx_B, tx_C;
    
    // Simulates the physical Pull-Up resistor
    assign can_bus = (tx_A === 1'b0 || tx_B === 1'b0 || tx_C === 1'b0) ? 1'b0 : 1'b1;

    // Explicit port mapping (stops elaboration compilation crashes)
    can_top ecu_A(.clk(clk), .rst(rst), .rx_in(can_bus), .tx_out(tx_A), .tx_request(tx_req_A), .tx_id(tx_id_A), .tx_dlc(4'd8), .tx_data(tx_data_A), .rx_valid(rx_val_A), .rx_id(rx_id_A), .rx_data(rx_data_A));
    can_top ecu_B(.clk(clk), .rst(rst), .rx_in(can_bus), .tx_out(tx_B), .tx_request(tx_req_B), .tx_id(tx_id_B), .tx_dlc(4'd8), .tx_data(tx_data_B), .rx_valid(rx_val_B), .rx_id(rx_id_B), .rx_data(rx_data_B));
    can_top ecu_C(.clk(clk), .rst(rst), .rx_in(can_bus), .tx_out(tx_C), .tx_request(tx_req_C), .tx_id(tx_id_C), .tx_dlc(4'd8), .tx_data(tx_data_C), .rx_valid(rx_val_C), .rx_id(rx_id_C), .rx_data(rx_data_C));

    always #10 clk = ~clk;
    
    // Latches to ensure we never miss a 1-clock valid pulse
    reg rx_c_caught, rx_a_caught;
    always @(posedge clk) begin
        if (rx_val_C) rx_c_caught <= 1;
        if (rx_val_A) rx_a_caught <= 1;
    end

    reg [63:0] stored_A, stored_B;
    initial begin
        $dumpfile("can_calc_wave.vcd"); $dumpvars(0, tb_can_calc_network);
        clk = 0; rst = 1; tx_req_A = 0; tx_req_B = 0; tx_req_C = 0;
        rx_c_caught = 0; rx_a_caught = 0;
        
        #100 rst = 0; #3000;

        // --- STEP 1 ---
        $display("\n--- STEP 1 ---");
        tx_id_A = 11'h1A1; tx_data_A = 64'h12153524c0895e81;
        $display("ECU A Transmitting ID: %h Data: %h", tx_id_A, tx_data_A);
        
        @(posedge clk) tx_req_A = 1; @(posedge clk) tx_req_A = 0;

        wait(rx_c_caught);
        stored_A = rx_data_C; 
        $display("ECU C Captured Data A: %h", stored_A);
        rx_c_caught = 0;
        #5000;

        // --- STEP 2 ---
        $display("\n--- STEP 2 ---");
        tx_id_B = 11'h2B2; tx_data_B = 64'h8484d609b1f05663;
        $display("ECU B Transmitting ID: %h Data: %h", tx_id_B, tx_data_B);
        
        @(posedge clk) tx_req_B = 1; @(posedge clk) tx_req_B = 0;

        wait(rx_c_caught);
        stored_B = rx_data_C; 
        $display("ECU C Captured Data B: %h", stored_B);
        rx_c_caught = 0;
        #5000;

        // --- STEP 3 ---
        $display("\n--- STEP 3 ---");
        tx_id_C = 11'h3C3; tx_data_C = stored_A + stored_B; 
        $display("ECU C Calculated Sum: %h", tx_data_C);
        
        @(posedge clk) tx_req_C = 1; @(posedge clk) tx_req_C = 0;

        wait(rx_a_caught);
        $display("\n--- FINAL VERIFICATION ---");
        $display("ECU A Received Sum: %h", rx_data_A);
        if (rx_data_A == (tx_data_A + tx_data_B)) $display("[SUCCESS] Distributed Math Network Verified!");
        else $display("[ERROR] Math Mismatch!");

        #2000 $finish;
    end
    
    initial begin
        #50000000; 
        $display("\n[FATAL] Watchdog Timeout! Simulation hung.");
        $finish;
    end
endmodule