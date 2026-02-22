`timescale 1ns / 1ps

module tb_can_top();
    reg clk, rst, tx_request;
    reg [10:0] tx_id; reg [3:0] tx_dlc; reg [63:0] tx_data;
    
    wire tx_out_uut, tx_out_listener;
    wire rx_valid; wire [10:0] rx_id; wire [63:0] rx_data;
    
    // THE CAN BUS: Wired-AND Logic (0 wins)
    wire can_bus = tx_out_uut & tx_out_listener; 

    // UUT: The Transmitter
    can_top uut (
        .clk(clk), .rst(rst), .rx_in(can_bus), .tx_out(tx_out_uut),
        .tx_request(tx_request), .tx_id(tx_id), .tx_dlc(tx_dlc), .tx_data(tx_data),
        .rx_valid(rx_valid), .rx_id(rx_id), .rx_data(rx_data),
        .tx_idle(), .rx_idle()
    );

    // LISTENER: Silent node to provide the ACK bit so the UUT doesn't hang!
    can_top listener (
        .clk(clk), .rst(rst), .rx_in(can_bus), .tx_out(tx_out_listener),
        .tx_request(1'b0), .tx_id(11'h0), .tx_dlc(4'h0), .tx_data(64'h0),
        .rx_valid(), .rx_id(), .rx_data(),
        .tx_idle(), .rx_idle()
    );

    always #10 clk = ~clk;

    // WATCHDOG TIMER: Will forcefully kill the sim if it takes too long
    initial begin
        #5000000; 
        $display("[ERROR] Simulation Timeout! (Watchdog Triggered)");
        $finish;
    end

    // SUCCESS CATCHER: Triggers immediately when a frame is validated
    always @(posedge clk) begin
        if (rx_valid) begin
            $display("[SUCCESS] Top-Level Loopback Verified! Data Received: %h", rx_data[7:0]);
            $finish;
        end
    end

    initial begin
        $dumpfile("can_top_wave.vcd");
        $dumpvars(0, tb_can_top);
        clk = 0; rst = 1; tx_request = 0;
        tx_id = 11'h123; tx_dlc = 4'h1; tx_data = 64'h00000000000000AB;

        #100 rst = 0;
        #200;
        
        $display("--- APP LAYER: Requesting CAN Transmission (Loopback Mode) ---");
        @(posedge clk) tx_request = 1;
        @(posedge clk) tx_request = 0;
    end
endmodule