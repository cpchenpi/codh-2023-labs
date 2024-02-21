`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 20:25:18
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
    input  clk, rstn, flush, 
    input  [31:0] ctl_MEM,
    output [31:0] ctl_WB,
    input  [31:0] ir_MEM,
    output [31:0] ir_WB,
    input  [31:0] ra_MEM,
    output [31:0] ra_WB,
    input  [31:0] rdata_MEM,
    output [31:0] rdata_WB,
    input  [31:0] alu_y_MEM,
    output [31:0] alu_y_WB
    );

    localparam NOP = 32'h0000_0033;

    register #(.WIDTH (32)) CTL_MEM_WB (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (flush ? 32'b0 : ctl_MEM),
        .q    (ctl_WB)
    );

    register #(.WIDTH (32)) IR_MEM_WB (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (flush ? NOP : ir_MEM),
        .q    (ir_WB)
    );

    register #(.WIDTH (32)) RA_MEM_WB (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (ra_MEM),
        .q    (ra_WB)
    );

    register #(.WIDTH (32)) RDATA_MEM_WB (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (rdata_MEM),
        .q    (rdata_WB)
    );

    register #(.WIDTH (32)) ALU_Y_MEM_WB (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (alu_y_MEM),
        .q    (alu_y_WB)
    );

endmodule
