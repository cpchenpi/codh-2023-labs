`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 22:41:56
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit(
    input reg_write_MEM, reg_write_WB,
    input [4:0] rd_MEM, rd_WB,
    input [4:0] rs1_EX, rs2_EX,
    output [1:0] forward_rs1, forward_rs2
    );

    localparam from_EX = 2'b00, from_MEM = 2'b01, from_WB = 2'b10;

    wire bypass_WB_rs1, bypass_WB_rs2, bypass_MEM_rs1, bypass_MEM_rs2;

    assign bypass_MEM_rs1 = reg_write_MEM && (rd_MEM != 0) && (rd_MEM == rs1_EX);
    assign bypass_MEM_rs2 = reg_write_MEM && (rd_MEM != 0) && (rd_MEM == rs2_EX);

    assign bypass_WB_rs1 = reg_write_WB && (rd_WB != 0) && (rd_WB == rs1_EX);
    assign bypass_WB_rs2 = reg_write_WB && (rd_WB != 0) && (rd_WB == rs2_EX);

    assign forward_rs1 = bypass_MEM_rs1 ? from_MEM : (bypass_WB_rs1 ? from_WB : from_EX);
    assign forward_rs2 = bypass_MEM_rs2 ? from_MEM : (bypass_WB_rs2 ? from_WB : from_EX);

endmodule
