`timescale 1ns / 1ps

module if_id (
    input  wire        clk,
    input  wire        rst,
    
    // Hazard Control
    input  wire        stall, // Freezes the register (holds old data)
    input  wire        flush, // Clears the register (inserts a NOP)
    
    // Inputs from Fetch Stage
    input  wire [31:0] if_pc,
    input  wire [31:0] if_instr,
    
    // Outputs to Decode Stage
    output reg  [31:0] id_pc,
    output reg  [31:0] id_instr
);

    always @(posedge clk) begin
        if (rst || flush) begin
            id_pc    <= 32'b0;
            // Insert a NOP (No Operation) instruction when flushing.
            // ADDI x0, x0, 0 is the standard RISC-V NOP (32'h00000013)
            id_instr <= 32'h00000013; 
        end else if (!stall) begin
            id_pc    <= if_pc;
            id_instr <= if_instr;
        end
    end

endmodule