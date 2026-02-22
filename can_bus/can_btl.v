`timescale 1ns / 1ps

module can_btl (
    input wire clk, rst, rx_sync_edge,
    output reg sample_point, tx_point
);
    reg [3:0] count;
    always @(posedge clk) begin
        if (rst) begin count <= 0; sample_point <= 0; tx_point <= 0; end
        else begin
            sample_point <= 0; tx_point <= 0;
            
            if (rx_sync_edge) count <= 0;
            else if (count == 9) count <= 0;
            else count <= count + 1;
            
            if (count == 0) tx_point <= 1;
            
            // THE MASTER FIX: Sample exactly in the middle of the 10-cycle bit!
            if (count == 4) sample_point <= 1; 
        end
    end
endmodule