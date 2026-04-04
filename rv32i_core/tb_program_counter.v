`default_nettype none
`timescale 1ns/1ps

module tb_program_counter;

    reg        clk;
    reg        reset;
    reg [31:0] pc_next;
    
    wire [31:0] pc;

    program_counter uut (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );

    reg [2:0] test_indicator=3'b000;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("program_counter.vcd");
        $dumpvars(0, tb_program_counter);

        reset = 1; pc_next = 32'h00000004;
        #10; test_indicator = test_indicator + 1;
        $display("Test 1 (Reset Asserted): Expected PC = 0, Got PC = %h", pc);
        
        reset = 0; 
        #10; test_indicator = test_indicator + 1;
        $display("Test 2 (Reset Released): Expected PC = 4, Got PC = %h", pc);

        pc_next = 32'h00000008;
        #10; test_indicator = test_indicator + 1;
        $display("Test 3 (Normal Count): Expected PC = 8, Got PC = %h", pc);

        pc_next = 32'h00000020;
        #10; test_indicator = test_indicator + 1;
        $display("Test 4 (Branch/Jump): Expected PC = 20, Got PC = %h", pc);

        reset = 1;
        #10; test_indicator = test_indicator + 1;
        $display("Test 5 (Asynchronous Reset): Expected PC = 0, Got PC = %h", pc);

        $finish;
    end

endmodule