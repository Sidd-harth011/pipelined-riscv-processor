`timescale 1ns / 1ps

module riscv_top (
    input  wire clk,
    input  wire rst
);

    // Wires to connect Core to Instruction Memory
    wire [31:0] imem_pc;
    wire [31:0] imem_instr;

    // Wires to connect Core to Data Memory
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wd;
    wire        dmem_we;
    wire [31:0] dmem_rd;

    // ------------------------------------------------------------------------
    // Instantiate the Processor Core
    // ------------------------------------------------------------------------
    riscv_core core_inst (
        .clk(clk),
        .rst(rst),
        .imem_pc(imem_pc),
        .imem_instr(imem_instr),
        .dmem_addr(dmem_addr),
        .dmem_wd(dmem_wd),
        .dmem_we(dmem_we),
        .dmem_rd(dmem_rd)
    );

    // ------------------------------------------------------------------------
    // Instantiate the Memories
    // ------------------------------------------------------------------------
    imem imem_inst (
        .pc(imem_pc),
        .instr(imem_instr)
    );

    dmem dmem_inst (
        .clk(clk),
        .we(dmem_we),
        .addr(dmem_addr),
        .wd(dmem_wd),
        .rd(dmem_rd)
    );

endmodule