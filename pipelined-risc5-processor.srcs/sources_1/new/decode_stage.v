`timescale 1ns / 1ps
`include "riscv_pkg.vh"

module decode_stage (
    input  wire [31:0] instr,

    // Sliced Register Addresses (Sent to reg_file.v)
    output wire [4:0]  rs1_addr,
    output wire [4:0]  rs2_addr,
    output wire [4:0]  rd_addr,

    // Sliced Instruction Control Fields
    output wire [6:0]  opcode,
    output wire [2:0]  funct3,
    output wire [6:0]  funct7,

    // Sign-Extended Immediate Value
    output reg  [31:0] imm
);

    // ------------------------------------------------------------------------
    // Combinational Logic: Instruction Decoder
    // ------------------------------------------------------------------------
    // RISC-V RV32I standard instruction formats
    assign opcode   = instr[6:0];
    assign rd_addr  = instr[11:7];
    assign funct3   = instr[14:12];
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign funct7   = instr[31:25];

    // ------------------------------------------------------------------------
    // Combinational Logic: Immediate Generator
    // ------------------------------------------------------------------------
    always @(*) begin
        case (opcode)
            // I-Type: ADDI, SLTI, LW, JALR
            `OPCODE_I_TYPE, `OPCODE_LOAD, `OPCODE_JALR:
                imm = {{20{instr[31]}}, instr[31:20]}; 
            
            // S-Type: SW, SH, SB
            `OPCODE_STORE:
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; 
                
            // B-Type: BEQ, BNE, BLT, BGE
            `OPCODE_BRANCH:
                imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; 
                
            // U-Type: LUI, AUIPC
            `OPCODE_LUI, `OPCODE_AUIPC:
                imm = {instr[31:12], 12'b0}; 
                
            // J-Type: JAL
            `OPCODE_JAL:
                imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; 
                
            default:
                imm = 32'b0;
        endcase
    end

endmodule