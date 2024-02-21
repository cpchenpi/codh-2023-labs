`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/11 16:53:12
// Design Name: 
// Module Name: sort_out
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


module sort_out(
    input clk, rstn,
    input run,
    input rxd,
    output txd,
    output done,
    output [15:0] cycles
    );

    wire [31:0] addr;
    wire [31:0] dout;
    wire [31:0] din;
    wire we;
    wire clk_ld;
        
    sdu_dm(
        .clk(clk),
        .rstn(rstn),
        .rxd(rxd),
        .txd(txd),
        .addr(addr),
        .dout(dout),
        .din(din),
        .we(we),
        .clk_ld(clk_ld)
    );
    
    sort SRT(
    	.clk    (clk),
        .rstn   (rstn),
        .run    (run),
        .done   (done),
        .cycles (cycles),
        .addr   (addr),
        .dout   (dout),
        .din    (din),
        .we     (we),
        .clk_ld (clk_ld)
    );
    
endmodule
