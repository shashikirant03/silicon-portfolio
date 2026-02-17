module mux2to1 (
    input  wire a,     // Input 0
    input  wire b,     // Input 1
    input  wire sel,   // Select signal
    output wire y      // Output
  );

  assign y = sel ? b : a;

  `ifdef FORMAL
    always @(*) begin
        if (sel)
            assert(y == b);
        else
            assert(y == a);
    end
  `endif
  
endmodule
