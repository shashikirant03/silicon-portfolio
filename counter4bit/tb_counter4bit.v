module tb_counter4bit;
    reg clk;
    reg rst;
    wire [3:0] count;

    // Instantiate the counter4bit module
    counter4bit uut (
        .clk(clk),
        .rst(rst),
        .count(count)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test sequence
    initial begin

        $dumpfile("simulation.vcd");
		$dumpvars(0, tb_counter4bit);
        // Initialize reset
        rst = 1; 
        #10; // Wait for 10 time units
        rst = 0; // Release reset

        // Wait for some time to observe the counting
        #1000; 

        // Finish the simulation
        $finish;
    end
endmodule