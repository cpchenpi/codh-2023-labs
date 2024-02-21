`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/03 23:43:06
// Design Name: 
// Module Name: register
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


module register #(
    parameter WIDTH = 16
)(
    input  clk, rstn, en,
    input  [WIDTH-1:0]  d,
    output reg  [WIDTH-1:0] q
);

always @(posedge clk, negedge rstn)
    if (!rstn) q <= 0;
    else  if (en)
        q <= d;

endmodule