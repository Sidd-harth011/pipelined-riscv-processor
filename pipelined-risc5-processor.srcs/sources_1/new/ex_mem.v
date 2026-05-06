`timescale 1ns / 1ps

module ex_mem (
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] ex_alu_result,
    input  wire [31:0] ex_rs2_data, // Forwarded data to store
    input  wire [4:0]  ex_rd_addr,
    
    input  wire        ex_mem_read,
    input  wire        ex_mem_write,
    input  wire        ex_mem_to_reg,
    input  wire        ex_reg_write,

    output reg  [31:0] mem_alu_result,
    output reg  [31:0] mem_rs2_data,
    output reg  [4:0]  mem_rd_addr,
    
    output reg         mem_mem_read,
    output reg         mem_mem_write,
    output reg         mem_mem_to_reg,
    output reg         mem_reg_write
);

    always @(posedge clk) begin
        if (rst) begin
            mem_alu_result <= 32'b0;
            mem_rs2_data   <= 32'b0;
            mem_rd_addr    <= 5'b0;
            mem_mem_read   <= 1'b0;
            mem_mem_write  <= 1'b0;
            mem_mem_to_reg <= 1'b0;
            mem_reg_write  <= 1'b0;
        end else begin
            mem_alu_result <= ex_alu_result;
            mem_rs2_data   <= ex_rs2_data;
            mem_rd_addr    <= ex_rd_addr;
            mem_mem_read   <= ex_mem_read;
            mem_mem_write  <= ex_mem_write;
            mem_mem_to_reg <= ex_mem_to_reg;
            mem_reg_write  <= ex_reg_write;
        end
    end

endmodule