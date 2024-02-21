`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 19:17:41
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(
    input clk, rstn, stall, flush,
    input [31:0] ir_IF, pc_IF,
    input [31:0] ra_IF,
    output [31:0] ir_ID, pc_ID,
    output [31:0] ra_ID
    );

    localparam NOP = 32'h0000_0033;

    register #(.WIDTH (32)) IR_IF_ID (
        .clk  (clk),
        .rstn (rstn),
        .en   (~stall),
        .d    (flush ? NOP : ir_IF),
        .q    (ir_ID)
    );

    register #(.WIDTH (32)) PC_IF_ID (
        .clk  (clk),
        .rstn (rstn),
        .en   (~stall),
        .d    (pc_IF),
        .q    (pc_ID)
    );

    register #(.WIDTH (32)) RA_IF_ID (
        .clk  (clk),
        .rstn (rstn),
        .en   (~stall),
        .d    (ra_IF),
        .q    (ra_ID)
    );

endmodule
