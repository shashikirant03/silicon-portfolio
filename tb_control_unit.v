`default_nettype none
`timescale 1ns/1ps

module tb_control_unit;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire        wen;
    wire        alu_src;
    wire        mem_write;
    wire        result_src;
    wire        branch;
    wire [3:0]  alu_ctrl;

    control_unit uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .wen(wen),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .result_src(result_src),
        .branch(branch),
        .alu_ctrl(alu_ctrl)
    );

    initial begin
        $dumpfile("control_unit.vcd");
        $dumpvars(0, tb_control_unit);

        $display("--- Starting Control Unit Test ---");

        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("R-Type ADD: wen=%b, alu_src=%b, alu_ctrl=%b (Expected: 1, 0, 0000)", wen, alu_src, alu_ctrl);

        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0100000; #10;
        $display("R-Type SUB: alu_ctrl=%b (Expected: 0001)", alu_ctrl);

        opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        $display("LOAD:       wen=%b, alu_src=%b, result_src=%b (Expected: 1, 1, 1)", wen, alu_src, result_src);

        opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        $display("STORE:      wen=%b, mem_write=%b (Expected: 0, 1)", wen, mem_write);

        opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("BRANCH:     branch=%b, alu_ctrl=%b (Expected: 1, 0001)", branch, alu_ctrl);

        #10;
        $display("--- Simulation Complete ---");
        $finish;
    end

endmodule