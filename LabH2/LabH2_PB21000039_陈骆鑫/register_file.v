`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/05 20:20:57
// Design Name: 
// Module Name: register_file
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


module  register_file (
    input         clk,		//时钟
    input  [4:0]  ra1, ra2,	//读地址
    output [31:0] rd1, rd2,	//读数据
    input  [4:0]  wa,		//写地址
    input  [31:0] wd,	    //写数据
    input         we		//写使能
);
    reg [31:0] rf[1:31]; 	//寄存器堆

    assign rd1 = ra1 ? rf[ra1] : 0; 	//读操作
    assign rd2 = ra2 ? rf[ra2] : 0;

    always @(posedge clk)
        if (we)
            if (wa) rf[wa] <= wd;   //写操作
endmodule

