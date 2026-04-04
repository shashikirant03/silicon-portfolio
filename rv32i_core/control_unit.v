`default_nettype none

module control_unit (
    input  wire [6:0] opcode,     // Bottom 7 bits of instruction
    input  wire [2:0] funct3,     // 3-bit function code (used to determine specific instruction within a category)
    input  wire [6:0] funct7,     // 7-bit function code (used to distinguish ADD/SUB and SRL/SRA)
    
    output reg        wen,        // 1 = Write to Register File
    output reg        alu_src,    // 0 = Register (ra2), 1 = Immediate
    output reg        mem_write,  // 1 = Write to Data RAM
    output reg        result_src, // 0 = ALU Result, 1 = RAM Data
    output reg        branch,     // 1 = Branch instruction
    output reg [3:0]  alu_ctrl    // 4-bit command to the ALU
);

    // 1. MAIN DECODER: Routes data paths based on the instruction category (Opcode)
    always @(*) begin
        wen        = 0; 
        alu_src    = 0;
        mem_write  = 0; 
        result_src = 0;
        branch     = 0;
        
        case (opcode)
            7'b0110011: begin // R-TYPE: Math using two registers
                wen = 1; alu_src = 0; result_src = 0;
            end
            7'b0010011: begin // I-TYPE: Math using one register + an immediate value
                wen = 1; alu_src = 1; result_src = 0;
            end
            7'b0000011: begin // LOAD: Read from RAM, save into a register
                wen = 1; alu_src = 1; result_src = 1;
            end
            7'b0100011: begin // STORE: Write register data into RAM
                wen = 0; alu_src = 1; mem_write = 1;
            end
            7'b1100011: begin // BRANCH: Compare two registers, trigger PC jump
                wen = 0; alu_src = 0; branch = 1; 
            end
            default: ; 
        endcase
    end

    // 2. ALU DECODER: Determines exact math operation based on Opcode, funct3, and funct7
    always @(*) begin 
        alu_ctrl = 4'b0000; // Default to ADD (used for address calculations in LOAD/STORE and as a safe default)
        
        if (opcode == 7'b0110011) begin // R-Type 
            case (funct3)
                3'b000: alu_ctrl = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB if funct7[5] is 1, else ADD
                3'b111: alu_ctrl = 4'b0010;                         // AND
                3'b110: alu_ctrl = 4'b0011;                         // OR
                3'b100: alu_ctrl = 4'b0100;                         // XOR
                3'b001: alu_ctrl = 4'b0101;                         // SLL (Shift Left Logical)
                3'b101: alu_ctrl = (funct7[5]) ? 4'b0111 : 4'b0110; // SRA if funct7[5] is 1, else SRL
                3'b010: alu_ctrl = 4'b1000;                         // SLT (Set Less Than Signed)
                3'b011: alu_ctrl = 4'b1001;                         // SLTU (Set Less Than Unsigned)
                default: alu_ctrl = 4'b0000;
            endcase
        end
        else if (opcode == 7'b0010011) begin // I-Type 
            case (funct3)
                3'b000: alu_ctrl = 4'b0000; // ADDI
                3'b111: alu_ctrl = 4'b0010; // ANDI
                3'b110: alu_ctrl = 4'b0011; // ORI
                3'b100: alu_ctrl = 4'b0100; // XORI
                default: alu_ctrl = 4'b0000;
            endcase
        end
        else if (opcode == 7'b1100011) begin // Branch Instructions
            alu_ctrl = 4'b0001; // Force ALU to SUBTRACT to check if rs1 == rs2 (Zero flag)
        end
    end

endmodule