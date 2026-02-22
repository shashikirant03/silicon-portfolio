module can_crc (
    input wire clk,
    input wire rst,
    input wire data_in,
    input wire enable,
    output reg [14:0] crc_reg
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            crc_reg <= 15'h0;
        end else if (enable) begin
            if (data_in ^ crc_reg[14])
                crc_reg <= {crc_reg[13:0], 1'b0} ^ 15'h4599;
            else
                crc_reg <= {crc_reg[13:0], 1'b0};
        end
    end
endmodule