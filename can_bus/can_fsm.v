`timescale 1ns / 1ps

module can_fsm (
    input  wire clk, rst, tx_request,
    input  wire [10:0] tx_id, input  wire [3:0]  tx_dlc, input  wire [63:0] tx_data,
    output reg         rx_valid, output reg  [10:0] rx_id, output reg  [3:0]  rx_dlc, output reg  [63:0] rx_data,
    output wire        rx_idle, tx_idle,
    input  wire rx_sync_edge, 
    input  wire tx_point, sample_point, tx_stall, rx_stall, rx_data_out,
    output wire tx_data_to_bsp, 
    output wire enable_tx_stuffing, enable_rx_stuffing, 
    input  wire [14:0] crc_in, output wire crc_enable, output reg  crc_reset
);

    localparam ST_IDLE=0, ST_SOF=1, ST_ARB=2, ST_CTRL=3, ST_DATA=4, ST_CRC=5, ST_CRC_DELIM=6, ST_ACK=7, ST_ACK_DELIM=8, ST_EOF=9;

    reg fsm_sample_point;
    always @(posedge clk) begin
        if (rst) fsm_sample_point <= 0;
        else fsm_sample_point <= sample_point && !rx_stall;
    end

    assign rx_idle = (rx_state == ST_IDLE);
    assign tx_idle = (tx_state == ST_IDLE);
    
    // THE FIX: Completely independent stuffing control
    assign enable_tx_stuffing = (tx_state >= ST_SOF && tx_state <= ST_CRC);
    assign enable_rx_stuffing = (rx_state >= ST_SOF && rx_state <= ST_CRC);

    // TX FSM
    reg [3:0] tx_state; reg [6:0] tx_bit_counter, data_bits_total;
    reg [10:0] latched_id; reg [3:0] latched_dlc; reg [63:0] latched_data;

    assign tx_data_to_bsp = (tx_state == ST_IDLE) ? 1'b1 :
                            (tx_state == ST_SOF)  ? 1'b0 :
                            (tx_state == ST_ARB)  ? latched_id[tx_bit_counter] :
                            (tx_state == ST_CTRL) ? ((tx_bit_counter >= 4) ? 1'b0 : latched_dlc[tx_bit_counter]) :
                            (tx_state == ST_DATA) ? latched_data[tx_bit_counter] :
                            (tx_state == ST_CRC)  ? crc_in[tx_bit_counter] : 1'b1;

    assign crc_enable = (tx_state >= ST_SOF && tx_state <= ST_DATA);

    always @(posedge clk) begin
        if (rst) begin tx_state <= ST_IDLE; crc_reset <= 0; tx_bit_counter <= 0; end 
        else begin
            crc_reset <= 0; 
            if (tx_state == ST_IDLE) begin
                if (tx_request) begin
                    latched_id <= tx_id; latched_dlc <= tx_dlc; latched_data <= tx_data;
                    data_bits_total <= tx_dlc * 8; crc_reset <= 1; tx_state <= ST_SOF;
                end
            end else if (tx_point && !tx_stall) begin
                case (tx_state)
                    ST_SOF: begin tx_bit_counter <= 10; tx_state <= ST_ARB; end
                    ST_ARB: begin if (tx_bit_counter == 0) begin tx_bit_counter <= 5; tx_state <= ST_CTRL; end else tx_bit_counter <= tx_bit_counter - 1; end
                    ST_CTRL: begin
                        if (tx_bit_counter == 0) begin
                            if (data_bits_total == 0) begin tx_bit_counter <= 14; tx_state <= ST_CRC; end 
                            else begin tx_bit_counter <= data_bits_total - 1; tx_state <= ST_DATA; end
                        end else tx_bit_counter <= tx_bit_counter - 1;
                    end
                    ST_DATA: begin if (tx_bit_counter == 0) begin tx_bit_counter <= 14; tx_state <= ST_CRC; end else tx_bit_counter <= tx_bit_counter - 1; end
                    ST_CRC: begin if (tx_bit_counter == 0) tx_state <= ST_CRC_DELIM; else tx_bit_counter <= tx_bit_counter - 1; end
                    ST_CRC_DELIM: tx_state <= ST_ACK;
                    ST_ACK:       tx_state <= ST_ACK_DELIM;
                    ST_ACK_DELIM: begin tx_bit_counter <= 6; tx_state <= ST_EOF; end
                    ST_EOF:       begin if (tx_bit_counter == 0) tx_state <= ST_IDLE; else tx_bit_counter <= tx_bit_counter - 1; end
                endcase
            end
        end
    end

    // RX FSM
    reg [3:0] rx_state; reg [6:0] rx_bit_counter;
    reg [10:0] shift_id; reg [3:0] shift_dlc; reg [63:0] shift_data;

    always @(posedge clk) begin
        if (rst) begin rx_state <= ST_IDLE; rx_valid <= 0; end 
        else begin
            rx_valid <= 0; 
            if (rx_state == ST_IDLE && rx_sync_edge) begin
                rx_state <= ST_SOF;
            end 
            else if (fsm_sample_point) begin
                case (rx_state)
                    ST_IDLE: begin end 
                    ST_SOF: begin rx_state <= ST_ARB; rx_bit_counter <= 10; end
                    ST_ARB: begin shift_id[rx_bit_counter] <= rx_data_out; if (rx_bit_counter == 0) begin rx_state <= ST_CTRL; rx_bit_counter <= 5; end else rx_bit_counter <= rx_bit_counter - 1; end
                    ST_CTRL: begin
                        if (rx_bit_counter < 4) shift_dlc[rx_bit_counter] <= rx_data_out;
                        if (rx_bit_counter == 0) begin
                            if ({shift_dlc[3:1], rx_data_out} == 0) begin rx_state <= ST_CRC; rx_bit_counter <= 14; end 
                            else begin rx_state <= ST_DATA; rx_bit_counter <= ({shift_dlc[3:1], rx_data_out} * 8) - 1; end
                        end else rx_bit_counter <= rx_bit_counter - 1;
                    end
                    ST_DATA: begin shift_data[rx_bit_counter] <= rx_data_out; if (rx_bit_counter == 0) begin rx_state <= ST_CRC; rx_bit_counter <= 14; end else rx_bit_counter <= rx_bit_counter - 1; end
                    ST_CRC: begin if (rx_bit_counter == 0) rx_state <= ST_CRC_DELIM; else rx_bit_counter <= rx_bit_counter - 1; end
                    ST_CRC_DELIM: rx_state <= ST_ACK;
                    ST_ACK:       rx_state <= ST_ACK_DELIM;
                    ST_ACK_DELIM: begin rx_state <= ST_EOF; rx_bit_counter <= 6; end
                    ST_EOF: begin
                        if (rx_bit_counter == 0) begin rx_state <= ST_IDLE; rx_id <= shift_id; rx_dlc <= shift_dlc; rx_data <= shift_data; rx_valid <= 1; end 
                        else rx_bit_counter <= rx_bit_counter - 1;
                    end
                endcase
            end
        end
    end
endmodule