`timescale 1ns / 1ps
`include "riscv_pkg.vh"

module control_unit (
    // Inputs from Decode Stage
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    
    // Outputs to Pipeline Registers
    output reg        reg_write,   // 1 = Write to Register File
    output reg        alu_src,     // 0 = Register, 1 = Immediate
    output reg        mem_write,   // 1 = Write to Data RAM
    output reg        mem_read,    // 1 = Read from Data RAM
    output reg        mem_to_reg,  // 0 = ALU Result, 1 = RAM Data
    output reg        branch,      // 1 = Branch Instruction
    output reg  [3:0] alu_ctrl     // 4-bit ALU Command
);

    always @(*) begin
        // Default all signals to 0 to prevent accidental latches/writes
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        mem_read   = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        alu_ctrl   = `ALU_ADD;

        case (opcode)
            `OPCODE_R_TYPE: begin
                reg_write = 1'b1;
                // Standard RV32I ALU decoding logic
                case (funct3)
                    3'b000: alu_ctrl = (funct7[5]) ? `ALU_SUB : `ALU_ADD;
                    3'b001: alu_ctrl = `ALU_SLL;
                    3'b010: alu_ctrl = `ALU_SLT;
                    3'b011: alu_ctrl = `ALU_SLTU;
                    3'b100: alu_ctrl = `ALU_XOR;
                    3'b101: alu_ctrl = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
                    3'b110: alu_ctrl = `ALU_OR;
                    3'b111: alu_ctrl = `ALU_AND;
                endcase
            end

            `OPCODE_I_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1; // Use Immediate
                case (funct3)
                    3'b000: alu_ctrl = `ALU_ADD; // ADDI
                    3'b010: alu_ctrl = `ALU_SLT; // SLTI
                    3'b011: alu_ctrl = `ALU_SLTU;// SLTIU
                    3'b100: alu_ctrl = `ALU_XOR; // XORI
                    3'b110: alu_ctrl = `ALU_OR;  // ORI
                    3'b111: alu_ctrl = `ALU_AND; // ANDI
                    3'b001: alu_ctrl = `ALU_SLL; // SLLI
                    3'b101: alu_ctrl = (funct7[5]) ? `ALU_SRA : `ALU_SRL; // SRLI / SRAI
                endcase
            end

            `OPCODE_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1; // Load from Memory
                alu_ctrl   = `ALU_ADD; // Address = rs1 + imm
            end

            `OPCODE_STORE: begin
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_ctrl  = `ALU_ADD; // Address = rs1 + imm
            end

            `OPCODE_BRANCH: begin
                branch   = 1'b1;
                // For a standard BEQ, we use SUB to check if a - b == 0
                alu_ctrl = `ALU_SUB; 
            end
            
            // Note: Jumps (JAL/JALR) and Upper Immediates (LUI/AUIPC) require 
            // slightly expanded control logic, omitted here for RV32I baseline clarity.
        endcase
    end

endmodule