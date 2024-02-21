`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/01 19:18:23
// Design Name: 
// Module Name: cpu_top
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


module cpu_top(
    input clk, clk_ld, rstn,
    output [31:0] ir, ctl,
    output [31:0] a, b, imm,
    output [31:0] y, mdr,
    input  [31:0] addr,
    output [31:0] pc, npc,
    output [31:0] dout_dm, dout_im, dout_rf,
    input  [31:0] din,
    input we_dm, we_im, debug,
    output [31:0] cnt_out,
    output led_out
    );
    register #(.WIDTH (32)) PC(
    	.clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (npc),
        .q    (pc)
    );
    
    dist_mem inst_mem (
        .a(debug ? addr[9:0] : pc[11:2]),       // input wire [9:0] a
        .d(din),                                // input wire [31:0] d
        .clk(debug ? clk_ld : clk),             // input wire clk
        .we(debug ? we_im : 1'b0),              // input wire we
        .spo(ir)                                // output wire [31:0] spo
    );

    assign dout_im = ir;

    wire reg_write;
    wire [31:0] write_data;

    register_file reg_file(
    	.clk    (clk),
        .ra1    (ir[19:15]),
        .ra2    (ir[24:20]),
        .ra_sdu (addr[4:0]),
        .rd1    (a),
        .rd2    (b),
        .rd_sdu (dout_rf),
        .wa     (ir[11:7]),
        .wd     (write_data),
        .we     (reg_write)
    );
    
    imm_gen IMM_GEN(
    	.ir  (ir),
        .imm (imm)
    );

    wire [2:0] alu_op, t;

    wire [31:0] alu_a;

    wire is_lui, is_auipc;

    assign alu_a = is_lui ? 0 : (is_auipc ? pc : a);

    wire alu_src;
    
    alu #(
        .WIDTH(32)
    ) ALU(
    	.a (alu_a),
        .b (alu_src ? imm : b),
        .f (alu_op),
        .y (y),
        .t (t)
    );

    wire mem_write;

    virt_mem_wrapper virt_mem (
    	.addr    (debug ? (32'h2000 + (addr << 2)) : y),
        .din     (debug ? din : b),
        .clk     (debug ? clk_ld : clk),
        .we      (debug ? we_dm : mem_write),
        .rstn    (rstn),
        .clk_cpu (clk),
        .dout    (mdr),
        .cnt_out (cnt_out),
        .led_out (led_out)
    );


    assign dout_dm = mdr;

    wire [31:0] pc_add_4, br_jal_pc;
    assign pc_add_4 = pc + 4;
    assign br_jal_pc = pc + {imm[30:0], 1'b0};

    wire [2:0] br_flags;
    wire is_jal, is_jalr;

    wire br_success;
    assign br_success = |(br_flags & t);

    wire br_jal_success;
    assign br_jal_success = br_success | is_jal;

    assign npc = is_jalr ? (y & ~32'b1) : (br_jal_success ? br_jal_pc : pc_add_4);

    wire mem_to_reg, ra_to_reg;

    assign write_data = mem_to_reg ? mdr : (ra_to_reg ? pc_add_4 : y);

    control_unit CONTROL(
    	.ir         (ir),
        .br_flags   (br_flags),
        .alu_op     (alu_op),
        .is_jal     (is_jal),
        .is_jalr    (is_jalr),
        .is_lui     (is_lui),
        .is_auipc   (is_auipc),
        .alu_src    (alu_src),
        .mem_to_reg (mem_to_reg),
        .ra_to_reg  (ra_to_reg),
        .mem_write  (mem_write),
        .reg_write  (reg_write)
    );

    // 15 bits
    assign ctl = {br_flags[2:0], alu_op[2:0], is_jal, is_jalr, is_lui, is_auipc, alu_src, mem_to_reg, ra_to_reg, mem_write, reg_write, 17'b0};
    
endmodule
