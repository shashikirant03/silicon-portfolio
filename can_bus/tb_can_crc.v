`timescale 1ns / 1ps

module tb_can_crc();

    reg clk;
    reg rst;
    reg bit_tick;
    reg crc_enable;
    reg crc_reset;
    reg data_in;
    wire [14:0] crc_out;

    can_crc uut (
        .clk(clk),
        .rst(rst),
        .bit_tick(bit_tick),
        .crc_enable(crc_enable),
        .crc_reset(crc_reset),
        .data_in(data_in),
        .crc_out(crc_out)
    );

    always #10 clk = ~clk;

    integer tick_cnt = 0;
    always @(posedge clk) begin
        if (rst) begin
            bit_tick <= 0;
            tick_cnt <= 0;
        end else begin
            tick_cnt <= tick_cnt + 1;
            if (tick_cnt == 3) begin
                bit_tick <= 1'b1;
                tick_cnt <= 0;
            end else begin
                bit_tick <= 1'b0;
            end
        end
    end

    initial begin
        $dumpfile("can_crc_wave.vcd");
        $dumpvars(0, tb_can_crc);

        clk = 0;
        rst = 1;
        crc_enable = 0;
        crc_reset = 0;
        data_in = 0;

        #50 rst = 0;

        @(posedge clk);
        crc_reset = 1;
        @(posedge clk);
        crc_reset = 0;

        $display("--- Starting CRC-15 Math Test ---");
        
        crc_enable = 1;

        data_in = 0; @(posedge bit_tick); $display("Bit 1 (0) ingested. Live CRC: %h", crc_out);
        data_in = 1; @(posedge bit_tick); $display("Bit 2 (1) ingested. Live CRC: %h", crc_out);
        data_in = 0; @(posedge bit_tick); $display("Bit 3 (0) ingested. Live CRC: %h", crc_out);
        data_in = 1; @(posedge bit_tick); $display("Bit 4 (1) ingested. Live CRC: %h", crc_out);
        data_in = 1; @(posedge bit_tick); $display("Bit 5 (1) ingested. Live CRC: %h", crc_out);
        data_in = 0; @(posedge bit_tick); $display("Bit 6 (0) ingested. Live CRC: %h", crc_out);
        data_in = 1; @(posedge bit_tick); $display("Bit 7 (1) ingested. Live CRC: %h", crc_out);
        data_in = 0; @(posedge bit_tick); $display("Bit 8 (0) ingested. Live CRC: %h", crc_out);

        @(posedge clk);
        crc_enable = 0;
        data_in = 1; 

        #200;
        $display("====================================");
        $display("Final Frozen CRC-15 Signature: %h", crc_out);
        $display("====================================");
        $display("--- Simulation Complete ---");
        $finish;
    end

endmodule