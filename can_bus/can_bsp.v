`timescale 1ns / 1ps

module can_bsp (
    input  wire clk,
    input  wire rst,
    
    input  wire sample_point,
    input  wire tx_point,

    input  wire rx_in,
    output reg  tx_out,

    input  wire tx_data_in,
    input  wire enable_stuffing,
    output reg  rx_data_out,
    output reg  tx_stall,
    output reg  rx_stall,
    output reg  stuff_err
);

    reg [2:0] tx_bit_count;
    reg       tx_prev_bit;
    reg       tx_is_stuffing;

    reg [2:0] rx_bit_count;
    reg       rx_prev_bit;
    reg       rx_is_stuffing;

    // TX PATH: Triggered exactly at the start of a new bit time
    always @(posedge clk) begin
        if (rst) begin
            tx_out         <= 1'b1;
            tx_stall       <= 1'b0;
            tx_bit_count   <= 3'd1;
            tx_prev_bit    <= 1'b1;
            tx_is_stuffing <= 1'b0;
        end else if (tx_point) begin
            if (enable_stuffing) begin
                if (tx_is_stuffing) begin
                    tx_out         <= ~tx_prev_bit;
                    tx_prev_bit    <= ~tx_prev_bit;
                    tx_bit_count   <= 3'd1;
                    tx_is_stuffing <= 1'b0;
                    tx_stall       <= 1'b0; 
                end else begin
                    tx_out <= tx_data_in;
                    if (tx_data_in == tx_prev_bit) begin
                        if (tx_bit_count == 3'd4) begin
                            tx_is_stuffing <= 1'b1;
                            tx_stall       <= 1'b1; 
                        end
                        tx_bit_count <= tx_bit_count + 1'b1;
                    end else begin
                        tx_bit_count <= 3'd1;
                    end
                    tx_prev_bit <= tx_data_in;
                end
            end else begin
                tx_out         <= tx_data_in;
                tx_prev_bit    <= tx_data_in;
                tx_bit_count   <= 3'd1;
                tx_stall       <= 1'b0;
                tx_is_stuffing <= 1'b0;
            end
        end
    end

    // RX PATH: Triggered exactly at the sample point (75% through bit)
    always @(posedge clk) begin
        if (rst) begin
            rx_data_out    <= 1'b1;
            rx_stall       <= 1'b0;
            stuff_err      <= 1'b0;
            rx_bit_count   <= 3'd1;
            rx_prev_bit    <= 1'b1;
            rx_is_stuffing <= 1'b0;
        end else if (sample_point) begin
            if (enable_stuffing) begin
                if (rx_is_stuffing) begin
                    if (rx_in == rx_prev_bit) begin
                        stuff_err <= 1'b1; 
                    end
                    rx_stall       <= 1'b0; 
                    rx_is_stuffing <= 1'b0;
                    rx_bit_count   <= 3'd1;
                    rx_prev_bit    <= rx_in;
                end else begin
                    rx_data_out <= rx_in;
                    if (rx_in == rx_prev_bit) begin
                        if (rx_bit_count == 3'd4) begin
                            rx_is_stuffing <= 1'b1;
                            rx_stall       <= 1'b1; 
                        end
                        rx_bit_count <= rx_bit_count + 1'b1;
                    end else begin
                        rx_bit_count <= 3'd1;
                    end
                    rx_prev_bit <= rx_in;
                end
            end else begin
                rx_data_out    <= rx_in;
                rx_prev_bit    <= rx_in;
                rx_bit_count   <= 3'd1;
                rx_stall       <= 1'b0;
                rx_is_stuffing <= 1'b0;
                stuff_err      <= 1'b0;
            end
        end
    end

endmodule