`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 19:17:18
// Design Name: 
// Module Name: IF
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


module IF(
    input alu_to_pc, br_jal_success,
    input clk, rstn, stall,
    input [31:0] alu_out, br_jal_pc,
    output [31:0] ir, pc, ra,       // 给流水线下一级
    output [31:0] npc               // 给SDU调试
    );

    assign ra = pc + 4;

    assign npc = br_jal_success ? br_jal_pc : (alu_to_pc ? (alu_out & ~32'b1) : ra);

    register #(.WIDTH (32)) PC (
        .clk  (clk),
        .rstn (rstn),
        .en   (~stall),
        .d    (npc),
        .q    (pc)
    );

    inst_mem INST_MEM (
        .a(pc[11:2]),       // input wire [9:0] a
        .spo(ir)           // output wire [31:0] spo
    );



endmodule
