`timescale 1ns / 1ps

module uart_tx #(
    parameter CLK_FREQ = 50000000, //50MHz
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_active, // Indicates if a transmission is in progress
    output reg        tx_serial, //Indicates the current state of the TX line (1 = idle/high, 0 = active/low)
    output reg        tx_done
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // State Definitions 
    localparam STATE_IDLE  = 3'b000;
    localparam STATE_START = 3'b001;
    localparam STATE_DATA  = 3'b010;
    localparam STATE_STOP  = 3'b011;
    localparam STATE_CLEAN = 3'b100;

    reg [2:0]  state = STATE_IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0]  bit_index = 0;
    reg [7:0]  tx_buffer = 0;

    always @(posedge clk) begin
        if (rst) begin
            state     <= STATE_IDLE;
            tx_active <= 0;
            tx_serial <= 1; // Idle => High 
            tx_done   <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
            
                STATE_IDLE: begin
                    tx_serial <= 1;
                    tx_done   <= 0;
                    if (tx_start == 1) begin
                        tx_buffer   <= tx_data; // Capture Data
                        state       <= STATE_START;
                        tx_active   <= 1;
                        clk_count   <= 0;
                    end
                end

                STATE_START: begin
                    tx_serial <= 0;
                    if (clk_count < (CLKS_PER_BIT[15:0] - 16'd1)) begin
                        clk_count <= clk_count + 1; //For start bit duration
                    end else begin
                        clk_count <= 0;
                        state     <= STATE_DATA;
                        bit_index <= 0;
                    end
                end

                STATE_DATA: begin
                    tx_serial <= tx_buffer[bit_index]; // Send current bit
                    
                    if (clk_count < (CLKS_PER_BIT[15:0] - 16'd1)) begin
                        clk_count <= clk_count + 1; // For data bit duration
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= STATE_STOP;
                        end
                    end
                end

                STATE_STOP: begin
                    tx_serial <= 1;
                    if (clk_count < (CLKS_PER_BIT[15:0] - 16'd1)) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state     <= STATE_CLEAN;
                    end
                end

                STATE_CLEAN: begin
                    tx_done   <= 1;
                    tx_active <= 0;
                    state     <= STATE_IDLE;
                end
                
                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule
