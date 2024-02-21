`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/11 11:37:34
// Design Name: 
// Module Name: sort
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


module sort (
    input  clk, 		    // 时钟
    input  rstn, 		    // 复位
    input  run,		        // 启动排序
    output reg done,		// 排序结束标志
    output [15:0] cycles,	// 排序耗费时钟周期数

    // SDU_DM接口
    input  [31:0] addr,	    // 读/写地址
    output [31:0] dout,	    // 读取数据
    input  [31:0] din,	    // 写入数据
    input  we,		        // 写使能
    input  clk_ld		    // 写时钟
);  
    wire [31:0] spo, dpo;
    wire [31:0] i_out, p_out, q_out, n_out;

    wire en_i, sel_i;
    register #(
        .WIDTH(32)
    ) REG_I (
    	.clk  (clk),
        .rstn (rstn),
        .en   (en_i),
        .d    (sel_i ? i_out + 1: 1),
        .q    (i_out)
    );

    wire en_p;
    register #(
        .WIDTH(32)
    ) REG_P (
    	.clk  (clk),
        .rstn (rstn),
        .en   (en_p),
        .d    (spo),
        .q    (p_out)
    );

    wire en_q;
    register #(
        .WIDTH(32)
    ) REG_Q (
    	.clk  (clk),
        .rstn (rstn),
        .en   (en_q),
        .d    (dpo),
        .q    (q_out)
    );

    wire en_n;
    register #(
        .WIDTH(32)
    ) REG_N (
    	.clk  (clk),
        .rstn (rstn),
        .en   (en_n),
        .d    (dpo),
        .q    (n_out)
    );

    wire en_flag, flag_in, flag_out;
    register #(
        .WIDTH(1)
    ) REG_FLAG (
    	.clk  (clk),
        .rstn (rstn),
        .en   (en_flag),
        .d    (flag_in),
        .q    (flag_out)
    );

    wire [31:0] a_in, d_in, dpra;
    wire sel_a, sel_d, sel_dpra;
    wire srt_we;
    assign a_in = (done ? addr : (sel_a ? (i_out + 1): i_out));
    assign d_in = sel_d ? q_out : p_out;
    assign dpra = sel_dpra ? 0 : (i_out + 1);
    
    dist_mem_gen_0 DM (
        .a(a_in[7:0]),                  // input wire [7:0] a
        .d((done ? din : d_in)),        // input wire [31:0] d
        .dpra(dpra[7:0]),               // input wire [7:0] dpra
        .clk(done ? clk_ld : clk),      // input wire clk
        .we(done ? we : srt_we),        // input wire we
        .spo(spo),                      // output wire [31:0] spo
        .dpo(dpo)                       // output wire [31:0] dpo
    );

    assign dout = spo;

    wire loop_bound, rev_order;

    assign loop_bound = (i_out == n_out - 1);
    assign rev_order = (p_out > q_out);

    wire run_ps;
    
    take_posedge  PS_RUN(
    	.x    (run),
        .clk  (clk),
        .rstn (rstn),
        .y    (run_ps)
    );
    
    wire done_rev;
    
    control_unit CU(
    	.clk        (clk),
        .rstn       (rstn),
        .run        (run_ps),
        .loop_bound (loop_bound),
        .rev_order  (rev_order),
        .flag_out   (flag_out),
        .sel_dpra   (sel_dpra),
        .en_n       (en_n),
        .en_flag    (en_flag),
        .flag_in    (flag_in),
        .en_i       (en_i),
        .sel_i      (sel_i),
        .sel_a      (sel_a),
        .en_p       (en_p),
        .en_q       (en_q),
        .sel_d      (sel_d),
        .srt_we     (srt_we),
        .done_rev   (done_rev)
    );

    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            done <= 1;
        end
        else done <= done ^ done_rev;
    end

    cycle_counter CCNT(
    	.clk    (clk),
        .rstn   (rstn),
        .done   (done),
        .cycles (cycles)
    );
endmodule
