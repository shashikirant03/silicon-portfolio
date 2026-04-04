`default_nettype none
`timescale 1ns/1ps

module tb_instruction_memory;

    reg  [31:0] pc;
    wire [31:0] instruction;

    instruction_memory uut (
        .pc(pc),
        .instruction(instruction)
    );

    initial begin
        $dumpfile("instruction_memory.vcd");
        $dumpvars(0, tb_instruction_memory);

        // Test reading address 0 (Array index 0)
        pc = 32'd0; 
        #10;
        $display("PC = %0d, Output = %h (Expected: 00000000)", pc, instruction);

        // Test reading address 4 (Array index 1)
        pc = 32'd4; 
        #10;
        $display("PC = %0d, Output = %h (Expected: 01002333)", pc, instruction);

        // Test reading address 8 (Array index 2)
        pc = 32'd8; 
        #10;
        $display("PC = %0d, Output = %h (Expected: 00500193)", pc, instruction);

        $finish;
    end

endmodule