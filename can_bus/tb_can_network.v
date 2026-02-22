`timescale 1ns / 1ps

module tb_can_network();

    reg clk;
    reg rst;

    // The Shared Physical Copper Wire (Wired-AND)
    wire can_bus;

    // ==========================================
    // ECU A
    // ==========================================
    reg         tx_req_A;
    reg  [10:0] tx_id_A;
    reg  [3:0]  tx_dlc_A;
    reg  [63:0] tx_data_A;
    wire        rx_val_A;
    wire [10:0] rx_id_A;
    wire [63:0] rx_data_A;
    wire        tx_out_A;

    can_top ecu_A (
        .clk(clk), .rst(rst),
        .rx_in(can_bus), .tx_out(tx_out_A),
        .tx_request(tx_req_A), .tx_id(tx_id_A), .tx_dlc(tx_dlc_A), .tx_data(tx_data_A),
        .rx_valid(rx_val_A), .rx_id(rx_id_A), .rx_dlc(), .rx_data(rx_data_A)
    );

    // ==========================================
    // ECU B
    // ==========================================
    reg         tx_req_B;
    reg  [10:0] tx_id_B;
    reg  [3:0]  tx_dlc_B;
    reg  [63:0] tx_data_B;
    wire        rx_val_B;
    wire [10:0] rx_id_B;
    wire [63:0] rx_data_B;
    wire        tx_out_B;

    can_top ecu_B (
        .clk(clk), .rst(rst),
        .rx_in(can_bus), .tx_out(tx_out_B),
        .tx_request(tx_req_B), .tx_id(tx_id_B), .tx_dlc(tx_dlc_B), .tx_data(tx_data_B),
        .rx_valid(rx_val_B), .rx_id(rx_id_B), .rx_dlc(), .rx_data(rx_data_B)
    );

    // ==========================================
    // ECU C
    // ==========================================
    reg         tx_req_C;
    reg  [10:0] tx_id_C;
    reg  [3:0]  tx_dlc_C;
    reg  [63:0] tx_data_C;
    wire        rx_val_C;
    wire [10:0] rx_id_C;
    wire [63:0] rx_data_C;
    wire        tx_out_C;

    can_top ecu_C (
        .clk(clk), .rst(rst),
        .rx_in(can_bus), .tx_out(tx_out_C),
        .tx_request(tx_req_C), .tx_id(tx_id_C), .tx_dlc(tx_dlc_C), .tx_data(tx_data_C),
        .rx_valid(rx_val_C), .rx_id(rx_id_C), .rx_dlc(), .rx_data(rx_data_C)
    );

    // ==========================================
    // THE PHYSICAL BUS
    // In CAN, 0 is dominant. If any node outputs 0, the bus is 0.
    // ==========================================
    assign can_bus = tx_out_A & tx_out_B & tx_out_C;

    // System Clock
    always #10 clk = ~clk;

    // Simulation Watchdog
    initial begin
        #800000; // Give it plenty of time to run both messages
        $display("\n[ERROR] Simulation Timeout!");
        $finish;
    end

    // Master Test Sequence
    initial begin
        $dumpfile("can_network_wave.vcd");
        $dumpvars(0, tb_can_network);

        // Boot up
        clk = 0; rst = 1;
        tx_req_A = 0; tx_id_A = 0; tx_dlc_A = 0; tx_data_A = 0;
        tx_req_B = 0; tx_id_B = 0; tx_dlc_B = 0; tx_data_B = 0;
        tx_req_C = 0; tx_id_C = 0; tx_dlc_C = 0; tx_data_C = 0;

        #100 rst = 0;
        #500;

        // ---------------------------------------------------------
        // SCENARIO 1: ECU A Broadcasts to B and C
        // ---------------------------------------------------------
        $display("\n============================================");
        $display("SCENARIO 1: ECU A is broadcasting...");
        tx_id_A   = 11'h111;
        tx_dlc_A  = 4'd1;
        tx_data_A = 64'hAA;

        @(posedge clk) tx_req_A = 1;
        @(posedge clk) tx_req_A = 0;

        // Wait for B and C to successfully receive the message
        fork
            begin
                @(posedge rx_val_B);
                $display(" -> ECU B Received | ID: %h | Data: %h", rx_id_B, rx_data_B[7:0]);
            end
            begin
                @(posedge rx_val_C);
                $display(" -> ECU C Received | ID: %h | Data: %h", rx_id_C, rx_data_C[7:0]);
            end
        join

        #5000; // Brief pause on the bus

        // ---------------------------------------------------------
        // SCENARIO 2: ECU B Broadcasts to A and C
        // ---------------------------------------------------------
        $display("\n============================================");
        $display("SCENARIO 2: ECU B is broadcasting...");
        tx_id_B   = 11'h222;
        tx_dlc_B  = 4'd1;
        tx_data_B = 64'hBB;

        @(posedge clk) tx_req_B = 1;
        @(posedge clk) tx_req_B = 0;

        // Wait for A and C to successfully receive the message
        fork
            begin
                @(posedge rx_val_A);
                $display(" -> ECU A Received | ID: %h | Data: %h", rx_id_A, rx_data_A[7:0]);
            end
            begin
                @(posedge rx_val_C);
                $display(" -> ECU C Received | ID: %h | Data: %h", rx_id_C, rx_data_C[7:0]);
            end
        join

        $display("\n============================================");
        $display("MULTI-NODE NETWORK TEST COMPLETE AND SUCCESSFUL!");
        #100;
        $finish;
    end

endmodule