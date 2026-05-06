`timescale 1ns / 1ps

module riscv_tb;

    // ------------------------------------------------------------------------
    // Testbench Signals
    // ------------------------------------------------------------------------
    reg clk;
    reg rst;

    // ------------------------------------------------------------------------
    // Instantiate the Top-Level Processor
    // ------------------------------------------------------------------------
    riscv_top uut (
        .clk(clk),
        .rst(rst)
    );

    // ------------------------------------------------------------------------
    // Clock Generation (100 MHz)
    // ------------------------------------------------------------------------
    always #5 clk = ~clk;

    // ------------------------------------------------------------------------
    // Simulation Sequence
    // ------------------------------------------------------------------------
    initial begin
        clk = 0;
        rst = 1;
        
        #20;
        rst = 0;
        
        #150;
        
        $display("\n========================================");
        $display("         SIMULATION COMPLETE            ");
        $display("========================================");
        $stop;
    end

    // ------------------------------------------------------------------------
    // THE AUTO-TRACKER (Prints results directly to Tcl Console)
    // ------------------------------------------------------------------------
    
    // 1. Track the ALU Output (The math calculations: sum, sub, etc.)
    // If you named the wire differently in riscv_core, update 'ex_alu_result'
    always @(uut.core_inst.ex_alu_result) begin
        if (!rst) begin
            $display("Time: %0t ns | ALU calculated new result: %0d (Hex: 0x%h)", 
                     $time, 
                     $signed(uut.core_inst.ex_alu_result), // Print as signed decimal
                     uut.core_inst.ex_alu_result);         // Print as hex
        end
    end

    // 2. Track Register Writes (When the math is saved to x1, x2, x3, etc.)
    always @(posedge clk) begin
        if (!rst && uut.core_inst.wb_reg_write && (uut.core_inst.wb_rd_addr != 5'b0)) begin
            $display("Time: %0t ns | -> Saved value %0d into Register x%0d", 
                     $time, 
                     $signed(uut.core_inst.wb_result), 
                     uut.core_inst.wb_rd_addr);
        end
    end

endmodule