`timescale 1ns / 1ps
`include "riscv_pkg.vh" // Pull in our macro dictionary

module alu (
    input  wire [31:0] a,          // Operand A (Usually rs1)
    input  wire [31:0] b,          // Operand B (Usually rs2 or Immediate)
    input  wire [3:0]  alu_ctrl,   // 4-bit control signal from Decode
    output reg  [31:0] result,     // Math result
    output wire        zero        // High if result is 0 (Used for Branching)
);

    // The zero flag is crucial for BEQ (Branch if Equal) instructions
    assign zero = (result == 32'b0);

    always @(*) begin
        case (alu_ctrl)
            `ALU_ADD:  result = a + b;
            `ALU_SUB:  result = a - b;
            `ALU_SLL:  result = a << b[4:0];                    // Shift Left Logical
            `ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // Set Less Than (Signed)
            `ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;        // Set Less Than (Unsigned)
            `ALU_XOR:  result = a ^ b;
            `ALU_SRL:  result = a >> b[4:0];                    // Shift Right Logical
            `ALU_SRA:  result = $signed(a) >>> b[4:0];          // Shift Right Arithmetic (Preserves sign)
            `ALU_OR:   result = a | b;
            `ALU_AND:  result = a & b;
            default:   result = 32'b0;                          // Default catch-all
        endcase
    end

endmodule