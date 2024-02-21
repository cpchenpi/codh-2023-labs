`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/29 21:09:26
// Design Name: 
// Module Name: alu_tb_handmade
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


module alu_tb_handmade();
    reg signed [31:0] a, b;
    reg [2:0] f;
    wire [31:0] y;
    wire [2:0] t;

    alu #(.WIDTH(32)) ALU (.a(a), .b(b), .f(f), .y(y), .t(t));


    initial begin
        // binary and decimal aritmetic test
        a = 5; b = 11; 
        f = 0; #1; f = 1; #1; f = 2; #1; f = 3; #1; f = 4; #1;
        a = 3; b = -4; 
        f = 0; #1; f = 1; #1; f = 2; #1; f = 3; #1; f = 4; #1;
        a = -5; b = -7; 
        f = 0; #1; f = 1; #1; f = 2; #1; f = 3; #1; f = 4; #1;
        a = 6; b = 6; 
        f = 0; #1; f = 1; #1; f = 2; #1; f = 3; #1; f = 4; #1;

        #2;

        // binary shift test
        a = 32'b1010_1001; b = 4;
        f = 5; #1; f = 6; #1; f = 7; #1;
        a = 32'b1111_1111_1111_1111_1111_1111_1011_0000; b = 8;
        f = 5; #1; f = 6; #1; f = 7; #1;
    end
endmodule
