`default_nettype none
`timescale 1ns/1ps

module tb_top;
    reg clk;
    reg reset;

    rv32i_core uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("cpu_test.vcd");
        $dumpvars(0, tb_top);
        
        // Reset the system
        reset = 1; #15;
        reset = 0;

        // Run for 100ns (enough for several instructions)
        #100;
        $finish;
    end
endmodule