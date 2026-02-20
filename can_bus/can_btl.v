`timescale 1ns / 1ps

module can_btl #(
    parameter BRP   = 4,  // Baud Rate Prescaler
    parameter TSEG1 = 11, // Sync_Seg + Prop_Seg + Phase_Seg1
    parameter TSEG2 = 4   // Phase_Seg2
)(
    input  wire clk,
    input  wire rst,
    input  wire rx_sync_edge, // Pulse for hard synchronization

    output reg  sample_point, // Pulse at end of TSEG1
    output reg  tx_point      // Pulse at end of TSEG2
);

    // 1. Define internal counters
    reg [15:0] clk_count;
    reg [15:0] tq_count;

    // 2. Main Logic Block
    always @(posedge clk) begin
        if (rst) begin
            // Reset everything to 0
            clk_count    <= 0;
            tq_count     <= 0;
            sample_point <= 1'b0;
            tx_point     <= 1'b0;
        end else begin
            // DEFAULT: Ensure pulses are 0 unless specifically triggered for 1 cycle
            sample_point <= 1'b0;
            tx_point     <= 1'b0;

            if (rx_sync_edge) begin
                // HARD SYNC: If the bus drops, reset counters to resynchronize with the bus timing
                clk_count <= 0;
                tq_count  <= 0;
            end else begin
                // NORMAL OPERATION
                if (clk_count == BRP - 1) begin
                    clk_count <= 0; // Reset the clock divider
                    
                    // Step A: Bit Rollover & TX Point Generation
                    if (tq_count == (TSEG1 + TSEG2 - 1)) begin
                        tq_count <= 0;    // End of the CAN bit, loop back to 0!
                        tx_point <= 1'b1; // Fire the 1-cycle TX pulse
                    end else begin
                        tq_count <= tq_count + 1; // Otherwise, move to next TQ
                    end

                    // Step B: Sample Point Generation
                    if (tq_count == TSEG1 - 1) begin
                        sample_point <= 1'b1; // Fire the 1-cycle Sample pulse
                    end

                end else begin
                    // If it didn't hit a TQ boundary, just increment the clock count
                    clk_count <= clk_count + 1;
                end
            end
        end
    end

endmodule