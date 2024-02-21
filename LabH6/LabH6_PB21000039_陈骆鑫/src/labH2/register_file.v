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
    input         clk,
    input  [4:0]  ra1, ra2,	//读地址
    input  [4:0]  ra_sdu,
    output [31:0] rd1, rd2,	//读数据
    output [31:0] rd_sdu,
    input  [4:0]  wa,		//写地址
    input  [31:0] wd,	    //写数据
    input         we		//写使能
);
    reg [31:0] rf[1:31]; 	//寄存器堆

    assign rd1 = ra1 ? ((ra1 == wa && we) ? wd : rf[ra1]) : 0; 	//读操作
    assign rd2 = ra2 ? ((ra2 == wa && we) ? wd : rf[ra2]) : 0;
    assign rd_sdu = ra_sdu ? ((ra_sdu == wa && we) ? wd : rf[ra_sdu]) : 0;

    // for test

    genvar i;
    generate
        for (i=1; i<32; i=i+1) begin
            initial begin
                rf[i] = 0;
            end
        end
    endgenerate

    

    always @(posedge clk)
        if (we) begin
            if (wa) begin
                rf[wa] <= wd;   //写操作
            end
        end
endmodule

