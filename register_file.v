`default_nettype none

module register_file (
    input  wire        clk,      
    input  wire        wen, // Write Enable (1 = Write, 0 = Read Only)
    
    // Read Port 1
    input  wire [4:0]  rs1, // 5-bit Read Address 1 (Source 1)
    output wire [31:0] rd1, // 32-bit Read Data 1
    
    // Read Port 2
    input  wire [4:0]  rs2,      
    output wire [31:0] rd2,     
    
    // Write Port
    input  wire [4:0]  ws,  // 5-bit Write Address (Destination)
    input  wire [31:0] wd   // 32-bit Write Data
);

    reg [31:0] ma [0:31];
    
    assign rd1 = (rs1 == 5'd0) ? 32'b0 : ma[rs1]; 
    assign rd2 = (rs2 == 5'd0) ? 32'b0 : ma[rs2]; 
    
    always @(posedge clk) begin
        if (wen && ws != 5'd0) begin
            ma[ws] <= wd;
        end
    end

endmodule