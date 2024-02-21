`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 20:25:28
// Design Name: 
// Module Name: WB
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


module WB(
    input [31:0] ir, ctl,
    input [31:0] ra,
    input [31:0] rdata, alu_y,
    output reg_write,
    output [4:0] waddr,
    output [31:0] wdata
    );

    wire mem_to_reg, ra_to_reg;

    assign mem_to_reg = ctl[20], ra_to_reg = ctl[19];
    assign reg_write = ctl[16];

    assign waddr = ir[11:7];
    assign wdata = mem_to_reg ? rdata : (ra_to_reg ? ra : alu_y);
endmodule
