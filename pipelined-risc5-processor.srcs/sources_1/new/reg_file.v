`timescale 1ns / 1ps

module reg_file (
    input  wire        clk,
    input  wire        rst,
    
    // Write Port (Used in Writeback Stage)
    input  wire        we,         // Write Enable
    input  wire [4:0]  rd_addr,    // Destination Register Address
    input  wire [31:0] rd_data,    // Data to write
    
    // Read Ports (Used in Decode Stage)
    input  wire [4:0]  rs1_addr,   // Source Register 1 Address
    input  wire [4:0]  rs2_addr,   // Source Register 2 Address
    output wire [31:0] rs1_data,   // Source Register 1 Data
    output wire [31:0] rs2_data    // Source Register 2 Data
);

    // 32 registers, each 32-bits wide
    reg [31:0] registers [31:0];
    integer i;

    // ------------------------------------------------------------------------
    // Read Logic (Combinational)
    // ------------------------------------------------------------------------
    // Rule 1: x0 is always 0.
    // Rule 2: If reading the same register we are currently writing, forward the new data.
    assign rs1_data = (rs1_addr == 5'b00000) ? 32'b0 : 
                      ((rs1_addr == rd_addr) && we) ? rd_data : registers[rs1_addr];
                      
    assign rs2_data = (rs2_addr == 5'b00000) ? 32'b0 : 
                      ((rs2_addr == rd_addr) && we) ? rd_data : registers[rs2_addr];

    // ------------------------------------------------------------------------
    // Write Logic (Sequential / Synchronous)
    // ------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            // Clear all registers on reset
            for (i = 1; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (we && (rd_addr != 5'b00000)) begin
            // Only write if Write Enable is high AND we aren't trying to overwrite x0
            registers[rd_addr] <= rd_data;
        end
    end

endmodule