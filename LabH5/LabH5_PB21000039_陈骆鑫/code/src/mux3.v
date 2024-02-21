`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 22:54:51
// Design Name: 
// Module Name: mux3
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


module mux3 #(parameter WIDTH = 32)(
    input  [WIDTH-1:0] d0, d1, d2,
    input  [1:0] sel,
    output [WIDTH-1:0] q
    );

    assign q = (sel == 2'd0) ? d0 : ((sel == 2'd1) ? d1 : d2);

endmodule
