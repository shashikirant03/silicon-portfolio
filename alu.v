`default_nettype none /* This directive prevents implicit wire declarations, 
which can help catch typos and other mistakes in signal names. */

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);

    assign zero = (result == 32'b0);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = a & b;
            4'b0011: result = a | b;
            4'b0100: result = a ^ b;
            4'b0101: result = a << b[4:0]; 
            4'b0110: result = a >> b[4:0];
            4'b0111: result = $signed(a) >>> b[4:0]; // The arithmetic right shift (>>>) preserves the sign bit for signed numbers.
            4'b1000: result = $signed(a) < $signed(b); 
            4'b1001: result = a < b;
            default: result = 32'b0; 
        endcase
    end

endmodule
