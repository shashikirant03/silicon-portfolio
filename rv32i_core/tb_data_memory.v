`default_nettype none
`timescale 1ns/1ps

module tb_data_memory;

    reg         clk;
    reg         wen;
    reg  [31:0] addr;
    reg  [31:0] wdata;
    wire [31:0] rdata;

    data_memory uut (
        .clk(clk),
        .wen(wen),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("data_memory.vcd");
        $dumpvars(0, tb_data_memory);

        wen   = 0;
        addr  = 32'b0;
        wdata = 32'b0;
        #10;

        $display("--- Starting Data Memory Test ---");

        // Test 1: Write to address 4 (Array index 1)
        wen   = 1;
        addr  = 32'd4;
        wdata = 32'hDEADBEEF;
        #10; // Wait for clock edge to write
        
        // Test 2: Read back from address 4
        wen   = 0; // Turn off write enable
        wdata = 32'h00000000; // Clear wdata to prove we are reading from RAM
        #10;
        $display("Read Addr 4:  %h (Expected: deadbeef)", rdata);

        // Test 3: Write to address 40 (Array index 10)
        wen   = 1;
        addr  = 32'd40;
        wdata = 32'hCAFEBABE;
        #10;

        // Test 4: Attempt to write without Write Enable (wen = 0)
        wen   = 0;
        addr  = 32'd40;
        wdata = 32'hBAD0BAD0; // This should NOT be written
        #10;
        
        // Read back address 40 to ensure the bad data was ignored
        $display("Read Addr 40: %h (Expected: cafebabe)", rdata);

        // Test 5: Read an uninitialized address (Address 8, Index 2)
        addr  = 32'd8;
        #10;
        $display("Read Addr 8:  %h (Expected: xxxxxxxx - uninitialized)", rdata);

        $display("--- Simulation Complete ---");
        $finish;
    end

endmodule