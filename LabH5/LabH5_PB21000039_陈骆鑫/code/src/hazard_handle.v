`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 23:17:45
// Design Name: 
// Module Name: hazard_handle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hazard_handle(
    input mem_read_EX, 
    input [4:0] EX_rd,
    input [4:0] ID_rs1, ID_rs2,
    output reg IF_stall, ID_stall,
    input jmp_EX,                           // br跳转，或jal/jalr跳转均要处理
    output EX_flush,
    output reg ID_flush
    );

    reg EX_flush_load, EX_flush_jmp;

    assign EX_flush = EX_flush_jmp || EX_flush_load;

    always @(*) begin
        if (mem_read_EX && EX_rd != 0 && (EX_rd == ID_rs1 || EX_rd == ID_rs2)) begin
            IF_stall = 1;
            ID_stall = 1;
            EX_flush_load = 1;
        end else begin
            IF_stall = 0;
            ID_stall = 0;
            EX_flush_load = 0;
        end
    end

    always @(*) begin
        if (jmp_EX) begin
            ID_flush = 1;
            EX_flush_jmp = 1;
        end else begin
            ID_flush = 0;
            EX_flush_jmp = 0;
        end
    end
endmodule
