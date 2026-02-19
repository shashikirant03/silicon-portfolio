module uart_tx #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_active,
    output reg        tx_serial,
    output reg        tx_done
);

    // 1. Constants
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // 2. State Definitions (Using localparam for broad compatibility)
    localparam STATE_IDLE  = 3'b000;
    localparam STATE_START = 3'b001;
    localparam STATE_DATA  = 3'b010;
    localparam STATE_STOP  = 3'b011;
    localparam STATE_CLEAN = 3'b100;

    // 3. Registers
    reg [2:0]  state = STATE_IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0]  bit_index = 0;
    reg [7:0]  tx_buffer = 0;

    // 4. Single-Process FSM (The "Safe" Way)
    always @(posedge clk) begin
        if (rst) begin
            state     <= STATE_IDLE;
            tx_active <= 0;
            tx_serial <= 1; // Idle High
            tx_done   <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                // --- IDLE STATE ---
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

                // --- START BIT (Drive Low) ---
                STATE_START: begin
                    tx_serial <= 0;
                    if (clk_count < (CLKS_PER_BIT[15:0] - 16'd1)) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state     <= STATE_DATA;
                        bit_index <= 0;
                    end
                end

                // --- DATA BITS (0-7) ---
                STATE_DATA: begin
                    tx_serial <= tx_buffer[bit_index]; // Send current bit
                    
                    if (clk_count < (CLKS_PER_BIT[15:0] - 16'd1)) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= STATE_STOP;
                        end
                    end
                end

                // --- STOP BIT (Drive High) ---
                STATE_STOP: begin
                    tx_serial <= 1;
                    if (clk_count < (CLKS_PER_BIT[15:0] - 16'd1)) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state     <= STATE_CLEAN;
                    end
                end

                // --- CLEANUP ---
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
