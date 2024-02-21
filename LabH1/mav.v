`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/03 23:41:36
// Design Name: 
// Module Name: mav
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


module  mav (
    input  clk, 
    input  rstn, 
    input  en,
    input  [15:0]  d,
    output [15:0]  m
);  
    wire [15:0] alu_out, mi1_out, mi2_out, mi3_out, cnt_out, sum3_out;
    debounce DB_EN(.x(en), .clk(clk), .rstn(rstn), .y(en_db));
    // assign en_db = en; // no debounce need while testing
    register #(.WIDTH(1)) EN_LS (.clk(clk), .rstn(rstn), .en(1), .d(en_db), .q(en_ls));
    assign en_ps = ~en_ls & en_db; 

    cnt CNT(.clk(clk), .rstn(rstn), .en(en_ps), .cnt_le2(cnt_le2));
    
    register #(.WIDTH(16)) ANS (.clk(clk), .rstn(rstn), .en(en_ps), .d(cnt_le2 ? d : {{2{alu_out[15]}}, alu_out[15:2]}), .q(m));
    register #(.WIDTH(16)) MI1 (.clk(clk), .rstn(rstn), .en(en_mis), .d(d), .q(mi1_out));
    register #(.WIDTH(16)) MI2 (.clk(clk), .rstn(rstn), .en(en_mis), .d(mi1_out), .q(mi2_out));
    register #(.WIDTH(16)) MI3 (.clk(clk), .rstn(rstn), .en(en_mis), .d(mi2_out), .q(mi3_out));
    register #(.WIDTH(16)) SUM3 (.clk(clk), .rstn(rstn), .en(en_sum3), .d(alu_out), .q(sum3_out));

    wire [2:0] f, t;
    alu #(.WIDTH(16)) ALU(.a(sum3_out), .b(sel_alu_b ? mi3_out : d), .f(f), .y(alu_out), .t(t));

    cu   CU(.clk(clk), .rstn(rstn), .en(en_ps), .sel_alu_b(sel_alu_b), .en_mis(en_mis), .en_sum3(en_sum3), .f(f));
endmodule
