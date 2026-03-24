`timescale 1ns / 1ps

module tb_apb_uart;

    // APB Bus Signals
    reg         PCLK;
    reg         PRESETn;
    reg  [31:0] PADDR;
    reg         PSEL;
    reg         PENABLE;
    reg         PWRITE;
    reg  [31:0] PWDATA;
    wire [31:0] PRDATA;
    wire        PREADY;
    wire        PSLVERR;

    // Physical wires
    wire tx_wire;
    wire rx_wire;

    // LOOPBACK TEST: Wire the UART's TX directly into its own RX!
    assign rx_wire = tx_wire; 

    apb_uart uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .rx(rx_wire),
        .tx(tx_wire)
    );

    // Generate 50 MHz Clock
    always #10 PCLK = ~PCLK; 

    // CPU Task: APB Write
    task apb_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge PCLK); // Wait for the next clock edge before starting the write transaction
            PSEL    <= 1;
            PADDR   <= addr;
            PWRITE  <= 1;
            PWDATA  <= data;
            PENABLE <= 0;
            @(posedge PCLK); // Wait for setup phase
            PENABLE <= 1;
            @(posedge PCLK); // Wait for transfer phase
            PSEL    <= 0;
            PENABLE <= 0;
            PWRITE  <= 0;
        end
    endtask

    // CPU Task: APB Read
    task apb_read(input [31:0] addr, output [31:0] data);
        begin
            @(posedge PCLK); 
            PSEL    <= 1;
            PADDR   <= addr;
            PWRITE  <= 0;
            PENABLE <= 0;
            @(posedge PCLK);
            PENABLE <= 1;
            @(posedge PCLK);
            data    = PRDATA; 
            PSEL    <= 0;
            PENABLE <= 0;
        end
    endtask

    reg [31:0] read_data;

    initial begin
        $dumpfile("apb_uart.vcd");
        $dumpvars(0, tb_apb_uart);

        PCLK    = 0;
        PRESETn = 0;
        PSEL    = 0;
        PENABLE = 0;
        PWRITE  = 0;
        PADDR   = 0;
        PWDATA  = 0;

        #100;
        PRESETn = 1;
        #50;

        $display("\n--- CPU: Starting UART Loopback Test ---");

        // 1. CPU Writes 0x55 to the TX Register (Address 0x00)
        $display("CPU: Writing 0x55 to Address 0x00...");
        apb_write(32'h0000_0000, 32'h0000_0055);

        // 2. CPU Polls the Status Register (Address 0x08)
        $display("CPU: Polling Status Register... waiting for UART hardware to transmit bits...");
        read_data = 0;
        
        // Bit 1 is the rx_valid_flag. Loop until it goes HIGH.
        while ((read_data & 32'h0000_0002) == 0) begin // Check if bit 1 (rx_valid_flag) is 0
            apb_read(32'h0000_0008, read_data);
            #10000; // Wait some time before polling again to avoid spamming the console
        end

        // 3. CPU Reads the RX Register (Address 0x04)
        $display("CPU: RX_VALID Flag detected! Reading Address 0x04...");
        apb_read(32'h0000_0004, read_data);
        
        $display("CPU: Data Received = 0x%h", read_data[7:0]);
        if (read_data[7:0] == 8'h55) begin
            $display("--- TEST PASSED: APB Wrapper successfully integrated! ---\n");
        end else begin
            $display("--- TEST FAILED ---\n");
        end

        #200;
        $finish;
    end
endmodule