module tb_alu;

    reg [63:0] a, b;
    reg [4:0] op;
    wire [63:0] result;

    alu uut (
        .a(a),
        .b(b),
        .op(op),
        .result(result)
    );

    integer i;

    initial begin

        $dumpfile("simulation.vcd");
		$dumpvars(0, tb_alu);
        
        for(i = 0; i < 32; i = i + 1) begin
            a = $random; b = $random; op = i; #10;
            $display("Operation %b: %h, %h => %h", op, a, b, result);
        end

        $finish;
    end
endmodule