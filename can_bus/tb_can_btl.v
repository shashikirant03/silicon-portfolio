`timescale 1ns / 1ps
module tb_can_btl();
    reg clk, rst, rx_sync_edge;
    wire sample_point, tx_point;

    // Notice: Removed the .BRP, .TSEG1, etc. parameters that caused the error
    can_btl uut (
        .clk(clk),
        .rst(rst),
        .rx_sync_edge(rx_sync_edge),
        .sample_point(sample_point),
        .tx_point(tx_point)
    );

    always #10 clk = ~clk;

    initial begin
        $dumpfile("can_btl_wave.vcd"); // Changed name to match what vvp expected
        $dumpvars(0, tb_can_btl);
        clk = 0; rst = 1; rx_sync_edge = 0;
        #100 rst = 0;
        #5000000 $finish;
    end
endmodule