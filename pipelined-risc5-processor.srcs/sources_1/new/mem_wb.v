`timescale 1ns / 1ps

module mem_wb (
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] mem_read_data,
    input  wire [31:0] mem_alu_result,
    input  wire [4:0]  mem_rd_addr,
    
    input  wire        mem_mem_to_reg,
    input  wire        mem_reg_write,

    output reg  [31:0] wb_read_data,
    output reg  [31:0] wb_alu_result,
    output reg  [4:0]  wb_rd_addr,
    
    output reg         wb_mem_to_reg,
    output reg         wb_reg_write
);

    always @(posedge clk) begin
        if (rst) begin
            wb_read_data  <= 32'b0;
            wb_alu_result <= 32'b0;
            wb_rd_addr    <= 5'b0;
            wb_mem_to_reg <= 1'b0;
            wb_reg_write  <= 1'b0;
        end else begin
            wb_read_data  <= mem_read_data;
            wb_alu_result <= mem_alu_result;
            wb_rd_addr    <= mem_rd_addr;
            wb_mem_to_reg <= mem_mem_to_reg;
            wb_reg_write  <= mem_reg_write;
        end
    end

endmodule