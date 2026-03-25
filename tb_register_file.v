`default_nettype none
`timescale 1ns/1ps

module tb_register_file;

    reg        clk;
    reg        wen;
    reg [4:0]  ra1;
    reg [4:0]  ra2;
    reg [4:0]  wa;
    reg [31:0] wd;

    wire [31:0] rd1;
    wire [31:0] rd2;

    register_file uut (
        .clk(clk),
        .wen(wen),
        .ra1(ra1),
        .rd1(rd1),
        .ra2(ra2),
        .rd2(rd2),
        .wa(wa),
        .wd(wd)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        $dumpfile("register_file.vcd");
        $dumpvars(0, tb_register_file);

        wen = 0; ra1 = 0; ra2 = 0; wa = 0; wd = 0;
        #10;
        
        $display("--- Starting Register File Test ---");

        @(negedge clk); 
        wen = 1; wa = 5; wd = 32'hDEADBEEF;
        @(negedge clk);
        wen = 0; 
        
        ra1 = 5; 
        #1;      
        $display("Test 1 (Write/Read x5): Expected = deadbeef, Got = %x", rd1);

        @(negedge clk);
        wen = 1; wa = 10; wd = 32'hCAFEBABE;
        @(negedge clk);
        wen = 0;
        
        ra1 = 5; ra2 = 10; 
        #1;
        $display("Test 2 (Dual Read): x5 = %x, x10 = %x", rd1, rd2);

        @(negedge clk);
        wen = 1; wa = 0; wd = 32'hFFFFFFFF;
        @(negedge clk);
        wen = 0;
        
        ra1 = 0; 
        #1;
        $display("Test 3 (The x0 Trap): Expected = 00000000, Got = %x", rd1);
        
        if (rd1 == 32'b0) 
            $display("SUCCESS: x0 successfully defended against the write!");
        else 
            $display("FAIL: x0 accepted data!");

        #20;
        $display("--- Simulation Complete ---");
        $finish;
    end

endmodule