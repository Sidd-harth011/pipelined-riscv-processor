`timescale 1ns / 1ps

module dmem (
    input  wire        clk,
    input  wire        we,         // Write Enable (High for Store instructions)
    input  wire [31:0] addr,       // Memory Address (Calculated by the ALU)
    input  wire [31:0] wd,         // Write Data (Usually rs2_data)
    output wire [31:0] rd          // Read Data (Sent to Writeback stage)
);

    // 1024 words of 32-bit memory (4KB total)
    reg [31:0] ram_array [0:1023];

    // Word-aligned addressing (divide by 4)
    wire [29:0] word_addr = addr[31:2];

    // Read asynchronously (Standard for simple pipeline data forwarding)
    assign rd = ram_array[word_addr];

    // Write synchronously
    always @(posedge clk) begin
        if (we) begin
            ram_array[word_addr] <= wd;
        end
    end

endmodule