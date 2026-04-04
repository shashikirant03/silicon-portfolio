`default_nettype none

module register_file (
    input  wire        clk,      
    input  wire        wen, 
    
    // Read Port 1
    input  wire [4:0]  ra1, // Read Address 1 (Source 1)
    output wire [31:0] rd1, // Read Data 1
    
    // Read Port 2
    input  wire [4:0]  ra2,      
    output wire [31:0] rd2,     
    
    // Write Port
    input  wire [4:0]  wa,  // Write Address (Destination)
    input  wire [31:0] wd   // Write Data
);

    reg [31:0] mem [0:31];
    
    assign rd1 = (ra1 == 5'd0) ? 32'b0 : mem[ra1]; 
    assign rd2 = (ra2 == 5'd0) ? 32'b0 : mem[ra2]; 
    
    always @(posedge clk) begin
        if (wen && wa != 5'd0) begin
            mem[wa] <= wd;
        end
    end

endmodule