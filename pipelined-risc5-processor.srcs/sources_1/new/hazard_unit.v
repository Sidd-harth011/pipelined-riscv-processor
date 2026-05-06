`timescale 1ns / 1ps

module hazard_unit (
    // Inputs for Data Forwarding (Checking future stages for needed data)
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,
    input  wire [4:0] ex_mem_rd,
    input  wire       ex_mem_reg_write,
    input  wire [4:0] mem_wb_rd,
    input  wire       mem_wb_reg_write,
    
    // Inputs for Load-Use Stalls
    input  wire [4:0] if_id_rs1,
    input  wire [4:0] if_id_rs2,
    input  wire [4:0] id_ex_rd,
    input  wire       id_ex_mem_read,
    
    // Inputs for Control Hazards (Branches)
    input  wire       pc_src, // 1 if a branch is actually taken
    
    // Outputs to Data Forwarding Multiplexers (in Execute stage)
    output reg  [1:0] forward_a, // 00 = Normal, 10 = Forward from MEM, 01 = Forward from WB
    output reg  [1:0] forward_b,
    
    // Outputs to Pipeline Registers
    output wire       stall_f,   // Stall Fetch (PC)
    output wire       stall_d,   // Stall Decode (IF/ID register)
    output wire       flush_d,   // Flush Decode
    output wire       flush_e    // Flush Execute (ID/EX register)
);

    // ------------------------------------------------------------------------
    // 1. Data Forwarding Logic (Solves Read-After-Write hazards)
    // ------------------------------------------------------------------------
    always @(*) begin
        // Forward A logic (rs1)
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b10; // Grab data from Memory stage
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_a = 2'b01; // Grab data from Writeback stage
        end else begin
            forward_a = 2'b00; // Normal register read
        end

        // Forward B logic (rs2)
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b10;
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_b = 2'b01;
        end else begin
            forward_b = 2'b00;
        end
    end

    // ------------------------------------------------------------------------
    // 2. Load-Use Stall Logic
    // ------------------------------------------------------------------------
    // If the instruction in Execute is a Load (LW), and the instruction in Decode
    // needs that exact register right now, we MUST stall for 1 cycle.
    wire lw_stall;
    assign lw_stall = id_ex_mem_read & ((id_ex_rd == if_id_rs1) | (id_ex_rd == if_id_rs2));

    // ------------------------------------------------------------------------
    // 3. Control Signal Assignments
    // ------------------------------------------------------------------------
    // If we take a branch, flush the instructions currently in Fetch and Decode
    assign flush_d = pc_src;
    
    // If we need a Load-Use stall OR we take a branch, flush the Execute stage
    assign flush_e = lw_stall | pc_src;
    
    // Freeze the PC and the IF/ID register during a Load-Use stall
    assign stall_f = lw_stall;
    assign stall_d = lw_stall;

endmodule