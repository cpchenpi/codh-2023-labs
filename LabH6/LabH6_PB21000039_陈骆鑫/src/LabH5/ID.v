`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 19:37:52
// Design Name: 
// Module Name: ID
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


module ID(
    input  clk,
    input  reg_write,           
    input  [4:0]  wa,
    input  [31:0] wd,           // 这三个信号由WB段提供   
    input  [31:0] ir,           // ID部分只需要ir
    input  [4:0]  ra_sdu,       // SDU读地址
    output [31:0] reg_a, reg_b,
    output [31:0] rd_sdu,       // SDU读出数据
    output [31:0] imm, ctl
    );

    register_file REG_FILE(
    	.clk    (clk),
        .ra1    (ir[19:15]),
        .ra2    (ir[24:20]),
        .ra_sdu (ra_sdu),
        .rd1    (reg_a),
        .rd2    (reg_b),
        .rd_sdu (rd_sdu),
        .wa     (wa),
        .wd     (wd),
        .we     (reg_write)
    );
    
    control_unit CU(
    	.ir  (ir),
        .ctl (ctl)
    );
    
    imm_gen IMM_GEN(
    	.ir  (ir),
        .imm (imm)
    );
    

endmodule
