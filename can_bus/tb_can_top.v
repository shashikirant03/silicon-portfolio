`timescale 1ns / 1ps

module tb_can_top();

    reg clk;
    reg rst;
    
    reg        tx_request;
    reg [10:0] tx_id;
    reg [3:0]  tx_dlc;
    reg [63:0] tx_data;

    wire        rx_valid;
    wire [10:0] rx_id;
    wire [3:0]  rx_dlc;
    wire [63:0] rx_data;

    wire tx_out;
    wire rx_in;

    // Loopback: The node listens to its own transmission
    assign rx_in = tx_out; 

    can_top uut (
        .clk(clk),
        .rst(rst),
        .rx_in(rx_in),
        .tx_out(tx_out),
        .tx_request(tx_request),
        .tx_id(tx_id),
        .tx_dlc(tx_dlc),
        .tx_data(tx_data),
        .rx_valid(rx_valid),
        .rx_id(rx_id),
        .rx_dlc(rx_dlc),
        .rx_data(rx_data)
    );

    always #10 clk = ~clk;

    // WATCHDOG TIMER (Standard Verilog-2001)
    initial begin
        #300000; // 300 us maximum simulation time
        $display("\n[ERROR] Simulation Timeout! rx_valid never went high.");
        $finish;
    end

    // MAIN TEST SEQUENCE
    initial begin
        $dumpfile("can_top_wave.vcd");
        $dumpvars(0, tb_can_top);

        clk = 0;
        rst = 1;
        tx_request = 0;
        tx_id = 0;
        tx_dlc = 0;
        tx_data = 0;

        #100 rst = 0;
        #500;
        
        tx_id   = 11'h123;         
        tx_dlc  = 4'd1;            
        tx_data = 64'hAB;  // Load 0xAB into the bottom 8 bits
        
        $display("--- APP LAYER: Requesting CAN Transmission ---");
        $display("SENDING -> ID: %h, DLC: %d, DATA: %h", tx_id, tx_dlc, tx_data);

        @(posedge clk);
        tx_request = 1;
        @(posedge clk);
        tx_request = 0;

        // Wait until the RX Brain successfully decodes the frame!
        @(posedge rx_valid);
        
        $display("\n--- APP LAYER: Frame Received! ---");
        $display("RECEIVED <- ID: %h, DLC: %d, DATA: %h", rx_id, rx_dlc, rx_data);
        
        if (rx_id == 11'h123 && rx_data[7:0] == 8'hAB) begin
            $display("\n[SUCCESS] Bidirectional Transmit/Receive perfectly matched!");
        end else begin
            $display("\n[ERROR] Received data did not match transmitted data.");
        end

        #100;
        $finish;
    end

endmodule