`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 20:08:37
// Design Name: 
// Module Name: EX
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


module EX(
    input [31:0] reg_a, reg_b,
    input [31:0] imm,
    input [31:0] pc,
    input [31:0] ctl,
    output [31:0] alu_y,
    output [31:0] br_jal_pc,
    output alu_to_pc, br_jal_success
    );

    wire [31:0] alu_a, alu_b;
    
    wire is_lui, is_auipc;
    assign is_lui = ctl[23], is_auipc = ctl[22];
    assign alu_a = is_lui ? 0 : (is_auipc ? pc : reg_a);

    wire alu_src;
    assign alu_src = ctl[21];
    assign alu_b = alu_src ? imm : reg_b;

    wire [2:0] alu_op;
    assign alu_op[2:0] = ctl[28:26];
    
    wire [2:0] cmp;

    alu #(.WIDTH (32)) ALU(
    	.a (alu_a),
        .b (alu_b),
        .f (alu_op),
        .y (alu_y),
        .t (cmp)
    );

    wire [2:0] br_flags;
    wire is_jal, is_jalr;

    assign br_flags[2:0] = ctl[31:29];
    assign is_jal = ctl[25], is_jalr = ctl[24];

    assign br_jal_success = is_jal | (|(br_flags & cmp));

    assign alu_to_pc = is_jalr;

    assign br_jal_pc = pc + {imm[30:0], 1'b0};

endmodule
