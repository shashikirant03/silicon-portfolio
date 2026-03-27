`default_nettype none

module data_memory (
    input  wire        clk,
    input  wire        wen,       
    input  wire [31:0] addr,    
    input  wire [31:0] wdata,      
    output wire [31:0] rdata       
);

    reg [31:0] ram [0:63];

    always @(posedge clk) begin // Synchronous Write
        if (wen) begin
            ram[addr[7:2]] <= wdata;
        end
    end

    // Asynchronous Read: Constantly output the data at the requested address
    assign rdata = ram[addr[7:2]];

endmodule