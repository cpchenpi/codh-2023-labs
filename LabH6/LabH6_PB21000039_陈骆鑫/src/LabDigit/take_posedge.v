`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 01:12:22
// Design Name: 
// Module Name: take_posedge
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

module take_posedge #(
    WIDTH = 1
)(
    input      [WIDTH-1:0] x,
    input          clk, rstn,
    output reg [WIDTH-1:0] y
    );
    reg [WIDTH-1:0] x_ls;
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            x_ls <= 0;
            y <= 0;
        end
        else begin
            y <= ~x_ls & x;
            x_ls <= x;
        end
    end
endmodule
