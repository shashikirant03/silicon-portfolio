`timescale 1ns / 1ps

module tb_can_crc();
    reg clk, rst, data_in, enable;
    wire [14:0] crc_reg;

    can_crc uut (
        .clk(clk), .rst(rst), .data_in(data_in), .enable(enable), .crc_reg(crc_reg)
    );

    always #10 clk = ~clk;

    initial begin
        $dumpfile("can_crc_wave.vcd");
        $dumpvars(0, tb_can_crc);
        clk = 0; rst = 1; data_in = 0; enable = 0;
        #100 rst = 0;

        $display("--- Starting CRC-15 Math Test ---");
        
        // Feed 8 bits into the CRC
        @(posedge clk) enable = 1; data_in = 0; $display("Bit 1 (0) ingested.");
        @(posedge clk) data_in = 1; $display("Bit 2 (1) ingested.");
        @(posedge clk) data_in = 0; $display("Bit 3 (0) ingested.");
        @(posedge clk) data_in = 1; $display("Bit 4 (1) ingested.");
        @(posedge clk) data_in = 1; $display("Bit 5 (1) ingested.");
        @(posedge clk) data_in = 0; $display("Bit 6 (0) ingested.");
        @(posedge clk) data_in = 1; $display("Bit 7 (1) ingested.");
        @(posedge clk) data_in = 0; $display("Bit 8 (0) ingested.");
        @(posedge clk) enable = 0;
        
        #50;
        $display("====================================");
        $display("Final Frozen CRC-15 Signature: %h", crc_reg);
        $display("====================================");
        $display("--- Simulation Complete ---");
        $finish;
    end
endmodule