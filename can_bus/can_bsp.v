`timescale 1ns / 1ps

module can_bsp(
    input wire clk, rst, sample_point, tx_point, rx_in, tx_data_in, 
    input wire enable_tx_stuffing, enable_rx_stuffing,
    output reg tx_out, rx_data_out, 
    output wire tx_stall, rx_stall
);
    reg [2:0] tx_ones, tx_zeros, rx_ones, rx_zeros;
    
    assign tx_stall = enable_tx_stuffing && (tx_ones == 5 || tx_zeros == 5);
    assign rx_stall = enable_rx_stuffing && (rx_ones == 5 || rx_zeros == 5);

    always @(posedge clk) begin
        if (rst) begin 
            tx_out <= 1; rx_data_out <= 1; 
            tx_ones <= 0; tx_zeros <= 0; rx_ones <= 0; rx_zeros <= 0; 
        end else begin
            // -----------------------------------------------------------------
            // TX LOGIC
            // -----------------------------------------------------------------
            if (tx_point) begin
                if (!enable_tx_stuffing) begin
                    tx_out <= tx_data_in;
                    tx_ones <= 0; tx_zeros <= 0;
                end else begin
                    if (tx_ones == 5) begin tx_out <= 0; tx_ones <= 0; tx_zeros <= 1; end
                    else if (tx_zeros == 5) begin tx_out <= 1; tx_zeros <= 0; tx_ones <= 1; end
                    else begin
                        tx_out <= tx_data_in;
                        if (tx_data_in) begin tx_ones <= tx_ones + 1; tx_zeros <= 0; end
                        else begin tx_zeros <= tx_zeros + 1; tx_ones <= 0; end
                    end
                end
            end
            
            // -----------------------------------------------------------------
            // RX LOGIC
            // -----------------------------------------------------------------
            if (sample_point) begin
                if (!enable_rx_stuffing) begin
                    rx_data_out <= rx_in;
                    rx_ones <= 0; rx_zeros <= 0;
                end else begin
                    
                    // THE MASTER FIX: RX must count the stuff bit towards the next sequence!
                    if (rx_ones == 5) begin 
                        rx_ones <= 0; rx_zeros <= 1; // The stuff bit was a 0, count it!
                    end else if (rx_zeros == 5) begin 
                        rx_zeros <= 0; rx_ones <= 1; // The stuff bit was a 1, count it!
                    end else begin
                        rx_data_out <= rx_in;
                        if (rx_in) begin rx_ones <= rx_ones + 1; rx_zeros <= 0; end
                        else begin rx_zeros <= rx_zeros + 1; rx_ones <= 0; end
                    end
                    
                end
            end
        end
    end
endmodule