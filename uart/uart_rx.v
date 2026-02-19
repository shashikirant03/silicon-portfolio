module uart_rx #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
  )(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx_serial,
    output reg        rx_active,
    output reg [7:0]  rx_data,
    output reg        rx_done
  );

  // 1. Constants
  localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

  // 2. State Definitions
  localparam STATE_IDLE   = 3'b000;
  localparam STATE_START  = 3'b001;
  localparam STATE_DATA   = 3'b010;
  localparam STATE_STOP   = 3'b011;
  localparam STATE_CLEAN  = 3'b100;

  // 3. Registers
  reg [2:0]  state = STATE_IDLE;
  reg [15:0] clk_count = 0;
  reg [2:0]  bit_index = 0;
  reg [7:0]  rx_buffer = 0;

  // 4. Single-Process FSM
  always @(posedge clk)
  begin
    if (rst)
    begin
      state     <= STATE_IDLE;
      rx_active <= 0;
      rx_data   <= 0;
      rx_done   <= 0;
      clk_count <= 0;
      bit_index <= 0;
      rx_buffer <= 0;
    end
    else
    begin
      case (state)
        // --- IDLE STATE ---
        STATE_IDLE:
        begin
          rx_done   <= 0;
          clk_count <= 0;
          bit_index <= 0;

          if (rx_serial == 0)
          begin // Start Bit Detected
            state     <= STATE_START;
            rx_active <= 1;
            // Wait half a bit width to sample in the middle
            clk_count <= (CLKS_PER_BIT[15:0] / 16'd2) - 16'd1;
          end
        end

        // --- START BIT (Verify) ---
        STATE_START:
        begin
          if (clk_count > 0)
          begin
            clk_count <= clk_count - 1;
          end
          else
          begin
            if (rx_serial == 0)
            begin // Confirm it's still Low
              state     <= STATE_DATA;
              clk_count <= CLKS_PER_BIT[15:0] - 16'd1; // Wait full bit for Data 0
              bit_index <= 0;
            end
            else
            begin
              state <= STATE_IDLE; // False alarm (Noise)
              rx_active <= 0;
            end
          end
        end

        // --- DATA BITS ---
        STATE_DATA:
        begin
          if (clk_count > 0)
          begin
            clk_count <= clk_count - 1;
          end
          else
          begin
            rx_buffer[bit_index] <= rx_serial; // Sample!

            if (bit_index < 7)
            begin
              bit_index <= bit_index + 1;
              clk_count <= CLKS_PER_BIT[15:0] - 16'd1; // Wait for next data bit
            end
            else
            begin
              // FIX: Must wait for the Stop Bit now!
              state     <= STATE_STOP;
              clk_count <= CLKS_PER_BIT[15:0] - 16'd1;
            end
          end
        end

        // --- STOP BIT ---
        STATE_STOP:
        begin
          if (clk_count > 0)
          begin
            clk_count <= clk_count - 1;
          end
          else
          begin
            state     <= STATE_CLEAN;
            rx_done   <= 1;
            rx_active <= 0;
            rx_data   <= rx_buffer; // Transfer buffer to output
          end
        end

        // --- CLEANUP ---
        STATE_CLEAN:
        begin
          rx_done <= 0;
          state   <= STATE_IDLE;
        end

        default:
          state <= STATE_IDLE;
      endcase
    end
  end
endmodule
