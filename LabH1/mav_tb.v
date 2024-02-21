`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 00:40:23
// Design Name: 
// Module Name: mav_tb
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


module mav_tb;
    reg  clk, rstn, en;
    reg  [15:0] d;
    wire [15:0] m;

    mav MAV(.clk(clk), .rstn(rstn), .en(en), .d(d), .m(m));

    initial begin
        forever begin
            clk = 0; #1; clk = 1; #1;
        end
    end

    initial begin
        en = 0; d = 0;
        rstn = 0; #1; rstn = 1; #1;
        en = 1; d = 2; #2;
        en = 0; #6;
        en = 1; d = 3; #2;
        en = 0; #6;
        en = 1; d = 4; #2;
        en = 0; #6;
        en = 1; d = 5; #2;
        en = 0; #6;
        en = 1; d = 6; #2;
        en = 0; #6;
        en = 1; d = 7; #2;
        en = 0; #6;
        en = 1; d = 8; #2;
        en = 0; #6;
        en = 1; d = 9; #2;
        en = 0; #6;
        en = 1; d = 10; #2;
        en = 0; #6;
    end
endmodule
