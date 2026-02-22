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

    assign can_bus = tx_A & tx_B & tx_C;

    can_top ecu_A(clk, rst, can_bus, tx_A, tx_req_A, tx_id_A, 4'd8, tx_data_A, rx_val_A, rx_id_A, , rx_data_A);
    can_top ecu_B(clk, rst, can_bus, tx_B, tx_req_B, tx_id_B, 4'd8, tx_data_B, rx_val_B, rx_id_B, , rx_data_B);
    can_top ecu_C(clk, rst, can_bus, tx_C, tx_req_C, tx_id_C, 4'd8, tx_data_C, rx_val_C, rx_id_C, , rx_data_C);

    always #10 clk = ~clk;
    
    // Unconditional display to catch corrupted IDs
    always @(posedge rx_val_C) $display("   [DEBUG] ECU C read a frame with ID: %h", rx_id_C);
    
    reg [63:0] stored_A, stored_B;
    integer seed;

    initial begin
        $dumpfile("can_calc_wave.vcd"); $dumpvars(0, tb_can_calc_network);
        seed = $time; clk = 0; rst = 1; #100 rst = 0; #500;

        $display("\n--- STEP 1 ---");
        tx_id_A = 11'h1A1; tx_data_A = {$random(seed), $random(seed)};
        $display("ECU A Transmitting ID: %h Data: %h", tx_id_A, tx_data_A);
        @(posedge clk) tx_req_A = 1; @(posedge clk) tx_req_A = 0;

        @(posedge rx_val_C);
        if (rx_id_C == 11'h1A1) begin stored_A = rx_data_C; $display("ECU C Captured Data A: %h", stored_A); end
        #5000;

        $display("\n--- STEP 2 ---");
        tx_id_B = 11'h2B2; tx_data_B = {$random(seed), $random(seed)};
        $display("ECU B Transmitting ID: %h Data: %h", tx_id_B, tx_data_B);
        @(posedge clk) tx_req_B = 1; @(posedge clk) tx_req_B = 0;

        @(posedge rx_val_C);
        if (rx_id_C == 11'h2B2) begin stored_B = rx_data_C; $display("ECU C Captured Data B: %h", stored_B); end
        #5000;

        $display("\n--- STEP 3 ---");
        tx_id_C = 11'h3C3; tx_data_C = stored_A + stored_B; 
        $display("ECU C Calculated Sum: %h", tx_data_C);
        @(posedge clk) tx_req_C = 1; @(posedge clk) tx_req_C = 0;

        @(posedge rx_val_A);
        $display("\n--- FINAL VERIFICATION ---");
        $display("ECU A Received Sum: %h", rx_data_A);
        if (rx_data_A == (tx_data_A + tx_data_B)) $display("[SUCCESS] Distributed Math Network Verified!");
        else $display("[ERROR] Math Mismatch! Expected %h", (tx_data_A + tx_data_B));

        #2000 $finish;
    end
endmodule