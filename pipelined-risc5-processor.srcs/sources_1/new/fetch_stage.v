`timescale 1ns / 1ps

module fetch_stage (
    input  wire        clk,
    input  wire        rst,
    
    // Hazard Unit Control Signals
    input  wire        stall_f,    // Freezes the PC (Used if Decode/Memory stages need time)
    
    // Branching Control (Comes from Execute Stage)
    input  wire        pc_src,     // 1 if we are branching/jumping, 0 for normal PC+4
    input  wire [31:0] target_pc,  // The new address to jump to
    
    // Outputs to Instruction Memory and Decode Stage
    output reg  [31:0] pc,         // Current Program Counter
    output wire [31:0] pc_plus_4   // Next sequential PC
);

    // ------------------------------------------------------------------------
    // Combinational Logic: Calculate Next PC
    // ------------------------------------------------------------------------
    assign pc_plus_4 = pc + 32'd4;
    
    // Multiplexer: Choose between normal PC+4 or a Branch Target
    wire [31:0] next_pc = (pc_src) ? target_pc : pc_plus_4;

    // ------------------------------------------------------------------------
    // Sequential Logic: Update the Program Counter
    // ------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            // Standard RISC-V boot address is often 0x00000000 or 0x000000B0
            pc <= 32'h00000000; 
        end else if (!stall_f) begin
            // Only update the PC if the pipeline isn't stalled
            pc <= next_pc;
        end
        // If stall_f is 1, the PC register holds its current value
    end

endmodule