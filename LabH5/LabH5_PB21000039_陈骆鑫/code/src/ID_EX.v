`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 19:38:04
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(
    input  clk, rstn, flush,
    input  [31:0] ra_ID, pc_ID,
    output [31:0] ra_EX, pc_EX,
    input  [31:0] ir_ID,
    output [31:0] ir_EX,
    input  [31:0] reg_a_ID, reg_b_ID,
    output [31:0] reg_a_EX, reg_b_EX,
    input  [31:0] imm_ID, ctl_ID,
    output [31:0] imm_EX, ctl_EX
    );

    localparam NOP = 32'h0000_0033;
    
    register #(.WIDTH (32)) RA_ID_EX (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (ra_ID),
        .q    (ra_EX)
    );
    
    register #(.WIDTH (32)) PC_ID_EX (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (pc_ID),
        .q    (pc_EX)
    );

    register #(.WIDTH (32)) IR_ID_EX (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (flush ? NOP : ir_ID),
        .q    (ir_EX)
    );

    register #(.WIDTH (32)) REG_A_ID_EX (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (flush ? 32'b0 : reg_a_ID),
        .q    (reg_a_EX)
    );

    register #(.WIDTH (32)) REG_B_ID_EX (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (flush ? 32'b0 : reg_b_ID),
        .q    (reg_b_EX)
    );

    register #(.WIDTH (32)) IMM_ID_EX (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (flush ? 32'b0 : imm_ID),
        .q    (imm_EX)
    );

    register #(.WIDTH (32)) CTL_ID_EX (
        .clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (flush ? 32'b0 : ctl_ID),
        .q    (ctl_EX)
    );

endmodule
