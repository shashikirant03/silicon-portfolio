`timescale 1ns/1ps

module tb_mux2to1;
    reg a, b, sel;    // Inputs are 'reg' in a testbench
    wire y;           // Output is a 'wire'

    // Instantiate your MUX
    mux2to1 uut (
        .a(a), .b(b), .sel(sel), .y(y)
    );

    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("simulation.vcd");
        $dumpfile("simulation.vcd");
        $dumpvars(0, tb_mux2to1);

        // Test cases
        a = 0; b = 1; sel = 0; #10; // Expected y = 0
        sel = 1;               #10; // Expected y = 1
        a = 1; sel = 0;        #10; // Expected y = 1
        $finish;
    end
endmodule