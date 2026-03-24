`timescale 1ns / 1ps

// Tells Verilator we intentionally ignore the upper bits of our 32-bit bus
/* verilator lint_off UNUSEDSIGNAL */

module apb_uart (
    // APB Bus Interface
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire [31:0] PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,   // 1 = Write, 0 = Read
    input  wire [31:0] PWDATA,
    output reg  [31:0] PRDATA,
    output wire        PREADY,
    output wire        PSLVERR,   // 1 = Error, 0 = OKAY

    // Physical External Pins
    input  wire        rx,
    output wire        tx
  );

  assign PREADY  = 1'b1;
  assign PSLVERR = 1'b0; // No bus errors

  wire [7:0] rx_data_out;
  wire       rx_done;

  wire [7:0] tx_data_in;
  reg        tx_start;
  wire       tx_active;

  reg rx_valid_flag;

  // --- DUMMY WIRES FOR UNUSED OUTPUTS ---
  wire unused_rx_active;
  wire unused_tx_done;

  // HIDE THE LEGACY HARDWARE FROM THE FORMAL SOLVER
  `ifndef FORMAL
          uart_rx legacy_rx (
            .clk(PCLK),
            .rst(~PRESETn),
            .rx_serial(rx),
            .rx_active(unused_rx_active),
            .rx_data(rx_data_out),
            .rx_done(rx_done)
          );

  uart_tx legacy_tx (
            .clk(PCLK),
            .rst(~PRESETn),
            .tx_start(tx_start),
            .tx_data(tx_data_in),
            .tx_active(tx_active),
            .tx_serial(tx),
            .tx_done(unused_tx_done)
          );
`endif

  assign tx_data_in = PWDATA[7:0];

  // APB Write Logic (Address 0x00)
  wire apb_write_req = PSEL & PENABLE & PWRITE;
  /*PSEL = 1 (CPU says: "Hey UART, I'm talking to you!")
    PWRITE = 1 (CPU says: "I want to write data to you.")
    PENABLE = 0 {During Setup phase; cycle 1}(CPU says: "I'm just setting up the wires, don't read the data yet.")
    PENABLE = 1 {During Transfer phase; cycle 2}(CPU says: "The data is stable. Grab it NOW!")*/

  always @(posedge PCLK or negedge PRESETn)
  begin
    if (!PRESETn)
    begin
      tx_start <= 1'b0;
    end
    else
    begin
      tx_start <= 1'b0; // Default state
      if (apb_write_req && (PADDR[7:0] == 8'h00))
      begin
        tx_start <= 1'b1; // Pulse for 1 clock cycle
      end
    end
  end

  // Status Register Logic (RX Valid Flag)
  wire apb_read_req = PSEL & !PWRITE;

  always @(posedge PCLK or negedge PRESETn)
  begin
    if (!PRESETn)
    begin
      rx_valid_flag <= 1'b0;
    end
    else
    begin
      if (rx_done)
      begin
        rx_valid_flag <= 1'b1; // Data arrived!
      end
      else if (apb_read_req && (PADDR[7:0] == 8'h04))
      begin
        rx_valid_flag <= 1'b0; // CPU read the data, clear the flag
      end
    end
  end

  // APB Read Logic (Address 0x04, 0x08)
  always @(*)
  begin
    PRDATA = 32'h0000_0000; // Default read value
    if (PSEL && !PWRITE)
    begin
      case (PADDR[7:0])
        8'h04:
          PRDATA = {24'd0, rx_data_out}; // RX Register //{24,8} => 32 bits; Zero padding upper 24 bits, RX data in lower 8 bits
        8'h08:
          PRDATA = {30'd0, rx_valid_flag, tx_active}; // Status Register //{30,1,1} => 32 bits; Zero padding upper 30 bits, rx_valid_flag at bit 1, tx_active at bit 0
        default:
          PRDATA = 32'h0000_0000;
      endcase
    end
  end


`ifdef FORMAL
  reg f_past_valid = 0;
  always @(posedge PCLK)
  begin
    f_past_valid <= 1'b1;

    if (!f_past_valid)
    begin
      assume(!PRESETn);
    end

    assume(PADDR == 32'h0000_0000 || PADDR == 32'h0000_0004 || PADDR == 32'h0000_0008);

    if (!PRESETn)
    begin
      assert(tx_start == 1'b0);
      assert(rx_valid_flag == 1'b0);
    end
    else if (f_past_valid)
    begin

      assert(PREADY == 1'b1);
      assert(PSLVERR == 1'b0);

      if (tx_start == 1'b1)
      begin
        assert($past(PSEL) == 1'b1);
        assert($past(PENABLE) == 1'b1);
        assert($past(PWRITE) == 1'b1);
        assert($past(PADDR[7:0]) == 8'h00);
      end

      if (!PSEL || PWRITE)
      begin
        assert(PRDATA == 32'h0000_0000);
      end
    end
  end
`endif

endmodule

/* verilator lint_on UNUSEDSIGNAL */
