module alu(
    input wire [64:0] a, b,
    input wire [5:0] op,
    output reg [64:0] result
  );

  always@(*)
  begin
    case(op)
      5'b00000:
        result = a + b;
      5'b00001:
        result = a - b;
      5'b00010:
        result = a * b;
      5'b00011:
        result = a / b;
      5'b00100:
        result = a << b;
      5'b00101:
        result = a >> b;
      5'b00110:
        result = a >>> b;
      5'b00111:
        result = a <<< b;
      5'b01000:
        result = a & b;
      5'b01001:
        result = a | b;
      5'b01010:
        result = a ^ b;
      5'b01011:
        result = ~(a & b);
      5'b01100:
        result = ~(a | b);
      5'b01101:
        result = ~(a ^ b);
      5'b01110:
        result = (a < b) ? 64'h1 : 64'h0;
      5'b01111:
        result = (a > b) ? 64'h1 : 64'h0;
      5'b10000:
        result = (a != b) ? 64'h1 : 64'h0;
      5'b10001:
        result = (a == b) ? 64'h1 : 64'h0;
      5'b10010:
        result = (a >= b) ? 64'h1 : 64'h0;
      5'b10011:
        result = (a <= b) ? 64'h1 : 64'h0;
      5'b10100:
        result = (a[0] | !b[0]) & (!a[0] | b[0]);
      5'b10101:
        result = !((a[0] | !b[0]) | (!a[0] | b[0]));
      5'b10110:
        result = a[0] & b[0];
      5'b10111:
        result = a[0] | b[0];
      5'b11000:
        result = a[0] ^ b[0];
      5'b11001:
        result = ~(a[0] & b[0]);
      5'b11010:
        result = ~(a[0] | b[0]);
      5'b11011:
        result = ~(a[0] ^ b[0]);
      5'b11100:
        result = (a[0] < b[0]) ? 64'h1 : 64'h0;
      5'b11101:
        result = (a[0] > b[0]) ? 64'h1 : 64'h0;
      5'b11110:
        result = (a[0] != b[0]) ? 64'h1 : 64'h0;
      5'b11111:
        result = (a[0] == b[0]) ? 64'h1 : 64'h0;
      default:
        result = 64'h0;
    endcase
  end
endmodule
