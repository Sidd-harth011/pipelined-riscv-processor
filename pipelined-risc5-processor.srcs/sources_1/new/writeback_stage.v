`timescale 1ns / 1ps

module writeback_stage (
    // Inputs from previous stages
    input  wire [31:0] alu_result, // Result from Execute
    input  wire [31:0] read_data,  // Result from Data Memory
    
    // Control Signal
    input  wire        mem_to_reg, // 0 = ALU, 1 = Memory
    
    // Output back to the Register File (rd_data)
    output wire [31:0] result
);

    // ------------------------------------------------------------------------
    // Writeback Multiplexer
    // ------------------------------------------------------------------------
    assign result = (mem_to_reg) ? read_data : alu_result;

endmodule