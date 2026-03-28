`default_nettype none

module rv32i_core (
    input wire clk,
    input wire reset
);

    // --- 1. Internal Wires ---
    wire [31:0] pc, pc_next, pc_plus4, instr;
    wire [31:0] rd1, rd2, wd, alu_result, read_data, imm_ext;
    wire [3:0]  alu_ctrl;
    wire        wen, alu_src, mem_write, result_src, branch, alu_zero;

    // --- 2. Program Counter Logic (The "Next PC" math) ---
    assign pc_plus4 = pc + 4;
    assign pc_next = (branch && alu_zero) ? (pc + imm_ext) : pc_plus4;

    program_counter pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );

    // --- 3. Instruction Fetch ---
    instruction_memory imem_inst (
        .pc(pc),
        .instruction(instr)
    );

    // --- 4. Control Unit (The Brain) ---
    control_unit cu_inst (
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .wen(wen),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .result_src(result_src),
        .branch(branch),
        .alu_ctrl(alu_ctrl)
    );

    // --- 5. Register File ---
    // Note: wd (Write Data) comes from either the ALU or the RAM
    assign wd = (result_src) ? read_data : alu_result;

    register_file rf_inst (
        .clk(clk),
        .wen(wen),
        .ra1(instr[19:15]),
        .ra2(instr[24:20]),
        .wa(instr[11:7]),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // --- 6. Immediate Generation (Sign Extension) ---
    // This turns the 12-bit immediate from the instruction into a 32-bit number
    assign imm_ext = {{20{instr[31]}}, instr[31:20]}; 

    // --- 7. ALU ---
    wire [31:0] alu_input_b = (alu_src) ? imm_ext : rd2;

    alu alu_inst (
        .a(rd1),
        .b(alu_input_b),
        .alucntrl(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

    // --- 8. Data Memory ---
    data_memory dmem_inst (
        .clk(clk),
        .wen(mem_write),
        .addr(alu_result),
        .wdata(rd2),
        .rdata(read_data)
    );

endmodule