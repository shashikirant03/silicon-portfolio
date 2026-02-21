`timescale 1ns / 1ps

module can_crc (
    input  wire clk,
    input  wire rst,
    
    // Timing and Control
    input  wire bit_tick,     // 1-cycle pulse when a valid bit is ready
    input  wire crc_enable,   // HIGH during fields that are CRC-protected
    input  wire crc_reset,    // 1-cycle pulse to wipe the register before a new frame
    
    // Data Interface
    input  wire data_in,      // The pure, destuffed bit coming from the BSP
    
    // Output
    output reg [14:0] crc_out // The live 15-bit mathematical signature
);

    // The CAN 2.0 CRC-15 Polynomial: x^15 + x^14 + x^10 + x^8 + x^7 + x^4 + x^3 + 1
    // In binary: 100 0101 1001 1001 = 15'h4599
    localparam [14:0] CRC_POLY = 15'h4599;

    wire crc_next;
    
    // The decision bit: XOR the incoming data bit with the highest bit of the CRC
    assign crc_next = data_in ^ crc_out[14];

    always @(posedge clk) begin
        if (rst || crc_reset) begin
            // Wipe the math engine clean for a new frame
            crc_out <= 15'd0;
        end else if (bit_tick && crc_enable) begin
            
            // The LFSR Math Engine
            if (crc_next) begin
                // Shift left by 1, fill lowest bit with 0, and XOR with the polynomial
                crc_out <= {crc_out[13:0], 1'b0} ^ CRC_POLY;
            end else begin
                // Just shift left by 1 and fill lowest bit with 0
                crc_out <= {crc_out[13:0], 1'b0};
            end
            
        end
    end

endmodule