`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/29 20:32:14
// Design Name: 
// Module Name: alu_tb
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


module alu_tb;
    reg [31:0] a, b;
    reg [2:0] f;
    wire [31:0] y;
    wire [2:0] t;

    alu #(.WIDTH(32)) ALU (.a(a), .b(b), .f(f), .y(y), .t(t));

    integer seed = 100;

    initial begin
            forever begin
            a = $random();
            f = $random();
            b = $random();
            if (f >= 5) begin
                b = b[4:0];
            end
            #5;
        end
    end
endmodule
