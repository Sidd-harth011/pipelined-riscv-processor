`timescale 1ns / 1ps

module riscv_tb;

    reg clk;
    reg rst;

    riscv_top uut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

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

    always @(uut.core_inst.ex_alu_result) begin
        if (!rst) begin
            $display("Time: %0t ns | ALU calculated new result: %0d (Hex: 0x%h)", 
                     $time, 
                     $signed(uut.core_inst.ex_alu_result), 
                     uut.core_inst.ex_alu_result);         
        end
    end

    always @(posedge clk) begin
        if (!rst && uut.core_inst.wb_reg_write && (uut.core_inst.wb_rd_addr != 5'b0)) begin
            $display("Time: %0t ns | -> Saved value %0d into Register x%0d", 
                     $time, 
                     $signed(uut.core_inst.wb_result), 
                     uut.core_inst.wb_rd_addr);
        end
    end

endmodule