`timescale 1ns / 1ps

module memory_stage (
    // Inputs from Execute Stage
    input  wire [31:0] alu_result, // The memory address calculated by ALU
    input  wire [31:0] rs2_data,   // The data we want to store (for SW)
    
    // Control Signals 
    input  wire        mem_write,  // 1 if Store (SW)
    input  wire        mem_read,   // 1 if Load (LW)
    
    // Outputs routed to dmem.v (at the top level)
    output wire [31:0] mem_addr,
    output wire [31:0] mem_wd,
    output wire        mem_we
);

    // Pass the ALU result straight through as the memory address
    assign mem_addr = alu_result;
    
    // Pass the rs2 register data straight through as the write payload
    assign mem_wd   = rs2_data;
    
    // Only enable writing if the control unit says so
    assign mem_we   = mem_write;

endmodule