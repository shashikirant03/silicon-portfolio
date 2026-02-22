`timescale 1ns / 1ps

module can_top (
    input  wire clk, rst, rx_in, output wire tx_out,
    input  wire        tx_request, input  wire [10:0] tx_id, input  wire [3:0]  tx_dlc, input  wire [63:0] tx_data,
    output wire        rx_valid, output wire [10:0] rx_id, output wire [3:0]  rx_dlc, output wire [63:0] rx_data
);

    wire sample_point, tx_point, tx_data_to_bsp, rx_data_out, tx_stall, rx_stall;
    wire enable_tx_stuffing, enable_rx_stuffing; // Split wires!
    wire [14:0] crc_out; wire crc_enable, crc_reset, rx_idle, tx_idle;

    reg q1, q2;
    always @(posedge clk) begin
        if (rst) begin q1 <= 1; q2 <= 1; end else begin q1 <= rx_in; q2 <= q1; end
    end
    wire rx_sync_edge = (~q1 & q2) && rx_idle && tx_idle; 

    can_btl uut_btl (.clk(clk), .rst(rst), .rx_sync_edge(rx_sync_edge), .sample_point(sample_point), .tx_point(tx_point));
    
    can_bsp uut_bsp (.clk(clk), .rst(rst), .sample_point(sample_point), .tx_point(tx_point), .rx_in(rx_in), .tx_out(tx_out), .tx_data_in(tx_data_to_bsp), 
                     .enable_tx_stuffing(enable_tx_stuffing), .enable_rx_stuffing(enable_rx_stuffing), 
                     .rx_data_out(rx_data_out), .tx_stall(tx_stall), .rx_stall(rx_stall));
    
    can_crc uut_crc (.clk(clk), .rst(rst), .bit_tick(tx_point), .crc_enable(crc_enable), .crc_reset(crc_reset), .data_in(tx_data_to_bsp), .crc_out(crc_out));
    
    can_fsm uut_fsm (.clk(clk), .rst(rst), .tx_request(tx_request), .tx_id(tx_id), .tx_dlc(tx_dlc), .tx_data(tx_data), .rx_valid(rx_valid), .rx_id(rx_id), .rx_dlc(rx_dlc), .rx_data(rx_data), .rx_idle(rx_idle), .tx_idle(tx_idle), 
                     .rx_sync_edge(rx_sync_edge), .tx_point(tx_point), .sample_point(sample_point), .tx_stall(tx_stall), .tx_data_to_bsp(tx_data_to_bsp), 
                     .enable_tx_stuffing(enable_tx_stuffing), .enable_rx_stuffing(enable_rx_stuffing), 
                     .rx_data_out(rx_data_out), .rx_stall(rx_stall), .crc_in(crc_out), .crc_enable(crc_enable), .crc_reset(crc_reset));
endmodule