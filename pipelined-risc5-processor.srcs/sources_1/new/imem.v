`timescale 1ns / 1ps

module imem (
    input  wire [31:0] pc,         // Program Counter (Current Address)
    output wire [31:0] instr       // 32-bit Instruction Output
);

    // 1024 words of 32-bit memory (4KB total)
    reg [31:0] rom_array [0:1023]; 

    // Load the compiled RISC-V program into memory
    initial begin
        $readmemh("program.mem", rom_array);
    end

    // The RISC-V PC is byte-addressed (goes up by 4). 
    // Our array is word-addressed (goes up by 1).
    // So we divide the PC by 4 (shift right by 2) to get the correct array index.
    wire [29:0] word_addr = pc[31:2];
    
    // Read asynchronously (ROM behavior)
    assign instr = rom_array[word_addr];

endmodule