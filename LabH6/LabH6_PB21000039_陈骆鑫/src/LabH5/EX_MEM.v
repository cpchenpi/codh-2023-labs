`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 20:08:47
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(
    input  clk, rstn, stall, 
    input  [31:0] ir_EX,
    output [31:0] ir_MEM,
    input  [31:0] reg_b_EX,
    output [31:0] wd_MEM,
    input  [31:0] alu_y_EX,
    output [31:0] alu_y_MEM,
    input  [31:0] ra_EX,
    output [31:0] ra_MEM,
    input  [31:0] ctl_EX,
    output [31:0] ctl_MEM
    );

    register #(.WIDTH (32)) IR_EX_MEM (
        .clk  (clk),
        .rstn (rstn),
        .en   (~stall),
        .d    (ir_EX),
        .q    (ir_MEM)
    );

    register #(.WIDTH (32)) WD_EX_MEM (
        .clk  (clk),
        .rstn (rstn),
        .en   (~stall),
        .d    (reg_b_EX),
        .q    (wd_MEM)
    );

    register #(.WIDTH (32)) Y_EX_MEM (
        .clk  (clk),
        .rstn (rstn),
        .en   (~stall),
        .d    (alu_y_EX),
        .q    (alu_y_MEM)
    );
     
    register #(.WIDTH (32)) RA_EX_MEM (
        .clk  (clk),
        .rstn (rstn),
        .en   (~stall),
        .d    (ra_EX),
        .q    (ra_MEM)
    );

    register #(.WIDTH (32)) CTL_EX_MEM (
        .clk  (clk),
        .rstn (rstn),
        .en   (~stall),
        .d    (ctl_EX),
        .q    (ctl_MEM)
    );

endmodule
