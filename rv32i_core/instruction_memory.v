`default_nettype none

module instruction_memory (
    input  wire [31:0] pc,
    output wire [31:0] instruction
);

    reg [31:0] rom [0:63];

    initial begin
        $readmemh("program.hex", rom); // Load instructions from a hex file. Each line corresponds to one instruction.
    end

    // pc[7:2] divides the address by 4 to access the correct array index.
    assign instruction = rom[pc[7:2]];

endmodule