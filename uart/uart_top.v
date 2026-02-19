module uart_top #(
    // DEFINING PARAMETERS (So SBY can override them!)
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx_serial,
    output wire       tx_serial,
    output wire [7:0] rx_data,
    output wire       rx_done
  );

    // Dummy wires for intentionally unused outputs
    wire unused_rx_active;
    wire unused_tx_active;
    wire unused_tx_done;

  // Instantiate UART Receiver
  uart_rx #(
            .CLK_FREQ(CLK_FREQ), // Pass the parameter down
            .BAUD_RATE(BAUD_RATE)
          ) uart_receiver (
            .clk(clk),
            .rst(rst),
            .rx_serial(rx_serial),
            .rx_active(unused_rx_active),
            .rx_data(rx_data),
            .rx_done(rx_done)
          );

  // Instantiate UART Transmitter
  uart_tx #(
            .CLK_FREQ(CLK_FREQ), // Pass the parameter down
            .BAUD_RATE(BAUD_RATE)
          ) uart_transmitter (
            .clk(clk),
            .rst(rst),
            .tx_start(rx_done), 
            .tx_data(rx_data),  
            .tx_active(unused_tx_active),       
            .tx_serial(tx_serial),
            .tx_done(unused_tx_done)         
          );

`ifdef FORMAL
    // --------------------------------------------------------
    // FORMAL VERIFICATION BLOCK
    // --------------------------------------------------------
    reg f_past_valid = 0;
    always @(posedge clk) f_past_valid <= 1;

    // Force reset on the very first cycle
    initial assume(rst);
    
    // Check Reset Behavior (Corrected for Synchronous Reset)
    always @(posedge clk) begin
        // If the reset WAS high on the previous clock cycle,
        // then the registers MUST be clean on this current cycle.
        if (f_past_valid && $past(rst)) begin
            assert(tx_serial == 1);
            assert(rx_done == 0);
        end
    end

    // COVER: Can we successfully receive 'B'?
    always @(posedge clk) begin
        cover(rx_done && rx_data == 8'h42); 
    end
`endif

endmodule
