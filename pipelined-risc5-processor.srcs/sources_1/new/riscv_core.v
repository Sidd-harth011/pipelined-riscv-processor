`timescale 1ns / 1ps

module riscv_core (
    input  wire        clk,
    input  wire        rst,
    
    // Connections to Instruction Memory
    output wire [31:0] imem_pc,
    input  wire [31:0] imem_instr,
    
    // Connections to Data Memory
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wd,
    output wire        dmem_we,
    input  wire [31:0] dmem_rd
);

    // ========================================================================
    // IF Wires
    // ========================================================================
    wire stall_f;
    wire [31:0] ex_branch_target;
    wire ex_pc_src;
    
    // ========================================================================
    // ID Wires
    // ========================================================================
    wire [31:0] id_pc, id_instr;
    wire stall_d, flush_d;
    wire [4:0]  id_rs1_addr, id_rs2_addr, id_rd_addr;
    wire [6:0]  id_opcode, id_funct7;
    wire [2:0]  id_funct3;
    wire [31:0] id_imm, id_rs1_data, id_rs2_data;
    wire id_reg_write, id_alu_src, id_mem_write, id_mem_read, id_mem_to_reg, id_branch;
    wire [3:0] id_alu_ctrl;

    // ========================================================================
    // EX Wires
    // ========================================================================
    wire flush_e;
    wire [31:0] ex_pc, ex_rs1_data, ex_rs2_data, ex_imm;
    wire [4:0]  ex_rs1_addr, ex_rs2_addr, ex_rd_addr;
    wire        ex_alu_src, ex_branch, ex_mem_read, ex_mem_write, ex_mem_to_reg, ex_reg_write;
    wire [3:0]  ex_alu_ctrl;
    wire [31:0] ex_alu_result;
    
    // Forwarding MUX Outputs
    wire [1:0]  forward_a, forward_b;
    wire [31:0] forwarded_a;
    wire [31:0] forwarded_b;

    // ========================================================================
    // MEM Wires
    // ========================================================================
    wire [31:0] mem_alu_result, mem_rs2_data;
    wire [4:0]  mem_rd_addr;
    wire        mem_mem_read, mem_mem_write, mem_mem_to_reg, mem_reg_write;

    // ========================================================================
    // WB Wires
    // ========================================================================
    wire [31:0] wb_read_data, wb_alu_result, wb_result;
    wire [4:0]  wb_rd_addr;
    wire        wb_mem_to_reg, wb_reg_write;

    // ========================================================================
    // 1. Fetch Stage
    // ========================================================================
    fetch_stage fetch_inst (
        .clk(clk), .rst(rst),
        .stall_f(stall_f),
        .pc_src(ex_pc_src),            
        .target_pc(ex_branch_target), 
        .pc(imem_pc)                  
    );

    if_id if_id_inst (
        .clk(clk), .rst(rst),
        .stall(stall_d), .flush(flush_d),
        .if_pc(imem_pc),
        .if_instr(imem_instr),
        .id_pc(id_pc), .id_instr(id_instr)
    );

    // ========================================================================
    // 2. Decode Stage
    // ========================================================================
    decode_stage decode_inst (
        .instr(id_instr),
        .rs1_addr(id_rs1_addr), .rs2_addr(id_rs2_addr), .rd_addr(id_rd_addr),
        .opcode(id_opcode), .funct3(id_funct3), .funct7(id_funct7),
        .imm(id_imm)
    );

    reg_file reg_file_inst (
        .clk(clk), .rst(rst),
        .we(wb_reg_write),
        .rd_addr(wb_rd_addr),
        .rd_data(wb_result),
        .rs1_addr(id_rs1_addr), .rs2_addr(id_rs2_addr),
        .rs1_data(id_rs1_data), .rs2_data(id_rs2_data)
    );

    control_unit control_inst (
        .opcode(id_opcode), .funct3(id_funct3), .funct7(id_funct7),
        .reg_write(id_reg_write), .alu_src(id_alu_src), .mem_write(id_mem_write),
        .mem_read(id_mem_read), .mem_to_reg(id_mem_to_reg), .branch(id_branch),
        .alu_ctrl(id_alu_ctrl)
    );

    id_ex id_ex_inst (
        .clk(clk), .rst(rst), .flush(flush_e),
        .id_pc(id_pc), .id_rs1_data(id_rs1_data), .id_rs2_data(id_rs2_data),
        .id_imm(id_imm), .id_rs1_addr(id_rs1_addr), .id_rs2_addr(id_rs2_addr),
        .id_rd_addr(id_rd_addr),
        .id_alu_src(id_alu_src), .id_alu_ctrl(id_alu_ctrl), .id_branch(id_branch),
        .id_mem_read(id_mem_read), .id_mem_write(id_mem_write), 
        .id_mem_to_reg(id_mem_to_reg), .id_reg_write(id_reg_write),
        .ex_pc(ex_pc), .ex_rs1_data(ex_rs1_data), .ex_rs2_data(ex_rs2_data),
        .ex_imm(ex_imm), .ex_rs1_addr(ex_rs1_addr), .ex_rs2_addr(ex_rs2_addr),
        .ex_rd_addr(ex_rd_addr),
        .ex_alu_src(ex_alu_src), .ex_alu_ctrl(ex_alu_ctrl), .ex_branch(ex_branch),
        .ex_mem_read(ex_mem_read), .ex_mem_write(ex_mem_write),
        .ex_mem_to_reg(ex_mem_to_reg), .ex_reg_write(ex_reg_write)
    );

    // ========================================================================
    // 3. Execute Stage
    // ========================================================================
    // Data Forwarding Multiplexers
    assign forwarded_a = (forward_a == 2'b10) ? mem_alu_result :
                         (forward_a == 2'b01) ? wb_result : ex_rs1_data;

    assign forwarded_b = (forward_b == 2'b10) ? mem_alu_result :
                         (forward_b == 2'b01) ? wb_result : ex_rs2_data;

    execute_stage execute_inst (
        .pc(ex_pc),
        .rs1_data(forwarded_a),
        .rs2_data(forwarded_b),
        .imm(ex_imm),
        .alu_src(ex_alu_src),
        .alu_ctrl(ex_alu_ctrl),
        .branch(ex_branch),
        .alu_result(ex_alu_result),
        .branch_target(ex_branch_target),
        .pc_src(ex_pc_src)
    );

    ex_mem ex_mem_inst (
        .clk(clk), .rst(rst),
        .ex_alu_result(ex_alu_result),
        .ex_rs2_data(forwarded_b), 
        .ex_rd_addr(ex_rd_addr),
        .ex_mem_read(ex_mem_read), .ex_mem_write(ex_mem_write),
        .ex_mem_to_reg(ex_mem_to_reg), .ex_reg_write(ex_reg_write),
        .mem_alu_result(mem_alu_result), .mem_rs2_data(mem_rs2_data),
        .mem_rd_addr(mem_rd_addr),
        .mem_mem_read(mem_mem_read), .mem_mem_write(mem_mem_write),
        .mem_mem_to_reg(mem_mem_to_reg), .mem_reg_write(mem_reg_write)
    );

    // ========================================================================
    // 4. Memory Stage
    // ========================================================================
    memory_stage memory_inst (
        .alu_result(mem_alu_result),
        .rs2_data(mem_rs2_data),
        .mem_write(mem_mem_write),
        .mem_read(mem_mem_read),
        .mem_addr(dmem_addr),
        .mem_wd(dmem_wd),
        .mem_we(dmem_we)
    );

    mem_wb mem_wb_inst (
        .clk(clk), .rst(rst),
        .mem_read_data(dmem_rd),
        .mem_alu_result(mem_alu_result),
        .mem_rd_addr(mem_rd_addr),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_reg_write(mem_reg_write),
        .wb_read_data(wb_read_data),
        .wb_alu_result(wb_alu_result),
        .wb_rd_addr(wb_rd_addr),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_reg_write(wb_reg_write)
    );

    // ========================================================================
    // 5. Writeback Stage
    // ========================================================================
    writeback_stage writeback_inst (
        .alu_result(wb_alu_result),
        .read_data(wb_read_data),
        .mem_to_reg(wb_mem_to_reg),
        .result(wb_result)
    );

    // ========================================================================
    // The Hazard Unit
    // ========================================================================
    hazard_unit hazard_inst (
        .if_id_rs1(id_rs1_addr),
        .if_id_rs2(id_rs2_addr),
        .id_ex_rs1(ex_rs1_addr),
        .id_ex_rs2(ex_rs2_addr),
        .id_ex_rd(ex_rd_addr),
        .id_ex_mem_read(ex_mem_read),
        .ex_mem_rd(mem_rd_addr),        
        .ex_mem_reg_write(mem_reg_write), 
        .mem_wb_rd(wb_rd_addr),        
        .mem_wb_reg_write(wb_reg_write), 
        .pc_src(ex_pc_src),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .stall_f(stall_f),
        .stall_d(stall_d),
        .flush_d(flush_d),
        .flush_e(flush_e)
    );

endmodule