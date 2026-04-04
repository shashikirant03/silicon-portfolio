`default_nettype none
`timescale 1ns/1ps

module tb_alu;

  reg  [31:0] a;
  reg  [31:0] b;
  reg  [3:0]  alu_ctrl;

  wire [31:0] result;
  wire        zero;

  alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
      );

  initial
  begin
    $dumpfile("alu.vcd");
    $dumpvars(0, tb_alu);

    $display("Starting ALU Simulation...");

    a = 32'd10;
    b = 32'd20;
    alu_ctrl = 4'b0000;
    #10;
    $display("ADD:  %d + %d = %d", a, b, result);

    a = 32'd15;
    b = 32'd15;
    alu_ctrl = 4'b0001;
    #10;
    $display("SUB:  %d - %d = %d (Zero Flag: %b)", a, b, result, zero);

    a = -32'd5;
    b = 32'd10;
    alu_ctrl = 4'b1000;
    #10;
    $display("SLT:  -5 < 10 = %d", result);

    a = -32'd5;
    b = 32'd10;
    alu_ctrl = 4'b1001;
    #10;
    $display("SLTU: Unsigned -5 < 10 = %d", result);

    a = -32'd16;
    b = 32'd2;
    alu_ctrl = 4'b0111;
    #10;
    $display("SRA:  -16 >>> 2 = %d", $signed(result));

    $display("Simulation Complete.");
    $finish;
  end

endmodule
