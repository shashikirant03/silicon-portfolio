module can_top (
    input wire clk, input wire rst, input wire rx_in, output wire tx_out,
    input wire tx_request, input wire [10:0] tx_id, input wire [3:0] tx_dlc, input wire [63:0] tx_data,
    output wire rx_valid, output wire [10:0] rx_id, output wire [63:0] rx_data,
    output wire tx_idle, output wire rx_idle
);
    wire sample_point, tx_point, tx_stall, rx_stall, rx_data_out, tx_bit;
    wire en_tx_stuf, en_rx_stuf, crc_en, crc_rst;
    wire [14:0] crc_val;

    can_btl btl_inst (.clk(clk), .rst(rst), .rx_sync_edge(1'b0), .sample_point(sample_point), .tx_point(tx_point));
    
    can_bsp bsp_inst (.clk(clk), .rst(rst), .sample_point(sample_point), .tx_point(tx_point), 
                      .rx_in(rx_in), .tx_data_in(tx_bit), .tx_out(tx_out), .rx_data_out(rx_data_out),
                      .tx_stall(tx_stall), .rx_stall(rx_stall), 
                      .enable_tx_stuffing(en_tx_stuf), .enable_rx_stuffing(en_rx_stuf));

    can_fsm fsm_inst (.clk(clk), .rst(rst), .tx_request(tx_request), .tx_id(tx_id), .tx_dlc(tx_dlc), .tx_data(tx_data),
                      .tx_point(tx_point), .sample_point(sample_point), .tx_stall(tx_stall), .rx_stall(rx_stall),
                      .rx_data_out(rx_data_out), .tx_data_to_bsp(tx_bit), .enable_tx_stuffing(en_tx_stuf), 
                      .enable_rx_stuffing(en_rx_stuf), .rx_valid(rx_valid), .rx_id(rx_id), .rx_data(rx_data),
                      .tx_idle(tx_idle), .rx_idle(rx_idle), .crc_in(crc_val), .crc_enable(crc_en), .crc_reset(crc_rst));

    // THE CRITICAL FIX: Smart CRC Routing.
    // If FSM says we are transmitting, compute CRC on tx_bit. If receiving, compute on rx_data_out.
    wire crc_data_mux = en_tx_stuf ? tx_bit : rx_data_out;

    can_crc crc_inst (.clk(clk), .rst(crc_rst), .data_in(crc_data_mux), .enable(crc_en), .crc_reg(crc_val));
endmodule