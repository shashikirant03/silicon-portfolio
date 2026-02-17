module counter4bit (
    input wire clk,
    input wire rst,
    output reg [3:0] count
  );
  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      count <= 4'b0000;
    end
    else
    begin
      count <= count + 1;
    end
  end

  `ifdef FORMAL
    // We use a sampled clock or the design clock for sequential assertions
    always @(posedge clk) begin
        if (!rst_n) begin
            // 1. Reset Check: Counter should be zero after reset
            assert(count == 0);
        end else begin
            if (en) begin
                // 2. Increment Check: count = past_count + 1
                // We use $past() to look at the previous clock cycle
                assert(count == $past(count) + 1'b1);
            end else begin
                // 3. Hold Check: Counter stays the same if not enabled
                assert(count == $past(count));
            end
        end
    end
    `endif

endmodule
