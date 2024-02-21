`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/05 13:29:22
// Design Name: 
// Module Name: alu_test
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


module alu_test(
    input [15:0] sw,
    input cl, cr,
    input clk, rstn,
    output reg [3:0] state,
    output     [2:0] t_out,
    output     [6:0] cn,
    output     [7:0] an
    );
    reg en_a, en_b, en_f;
    reg  [31:0] a_in, b_in;
    wire [31:0] a_out, b_out, alu_out;
    reg  [2:0] f_in;
    wire [2:0] f_out;
    register #(.WIDTH(32)) REG_A (.clk(clk), .rstn(rstn), .en(en_a), .d(a_in), .q(a_out));
    register #(.WIDTH(32)) REG_B (.clk(clk), .rstn(rstn), .en(en_b), .d(b_in), .q(b_out));
    register #(.WIDTH(3)) REG_F (.clk(clk), .rstn(rstn), .en(en_f), .d(f_in), .q(f_out));

    wire [2:0] t;
    alu #(.WIDTH(32)) ALU(.a(a_out), .b(b_out), .f(f_out), .t(t), .y(alu_out));
    register #(.WIDTH(3)) REG_T (.clk(clk), .rstn(rstn), .en(1), .d(t), .q(t_out));

    wire [15:0] sw_ps;
    wire [3:0] hd;
    take_posedge #(.WIDTH(16)) PS_SW (.x(sw), .clk(clk), .rstn(rstn), .y(sw_ps));
    encoder16_4 ECD(.in(sw_ps), .f(ipt), .out(hd));

    reg [1:0] sel_ddp;
    wire [31:0] ddp_in;
    selector4 #(.WIDTH(32)) SEL_DDP(.in0(a_out), .in1(b_out), .in2({29'd0, f_out}), .in3(alu_out), .sel(sel_ddp), .out(ddp_in));

    dynamic_display DDP(.clk(clk), .rstn(rstn), .d(ddp_in), .an(an), .cn(cn));

    debounce DB_cl(.x(cl), .clk(clk), .rstn(rstn), .y(cl_db));
    take_posedge PE_cl(.x(cl_db), .clk(clk), .rstn(rstn), .y(cl_ps));
    debounce DB_cr(.x(cr), .clk(clk), .rstn(rstn), .y(cr_db));
    take_posedge PE_cr(.x(cr_db), .clk(clk), .rstn(rstn), .y(cr_ps));

    
    parameter S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;
    reg [1:0] cs, ns;

    always @(posedge clk, negedge rstn) begin
        if (!rstn) cs <= S0;
        else cs <= ns;
    end

    always @(*) begin
        ns = cs;
        en_a = 0; en_b = 0; en_f = 0;
        a_in = a_out; b_in = b_out; f_in = f_out;
        sel_ddp = 0;
        state = 4'b0001;
        case (cs)
            S0: begin
                sel_ddp = 0;
                state = 4'b0001;
                if (ipt) begin
                    en_a = 1; a_in = {a_out[27:0], hd};
                end
                if (cl_ps) ns = S3;
                else if (cr_ps) ns = S1;
            end

            S1: begin
                sel_ddp = 1;
                state = 4'b0010;
                if (ipt) begin
                    en_b = 1; b_in = {b_out[27:0], hd};
                end
                if (cl_ps) ns = S0;
                else if (cr_ps) ns = S2;
            end

            S2: begin
                sel_ddp = 2;
                state = 4'b0100;
                if (ipt) begin
                    en_f = 1; f_in = hd[2:0];
                end
                if (cl_ps) ns = S1;
                else if (cr_ps) ns = S3;
            end

            S3: begin
                sel_ddp = 3;
                state = 4'b1000;
                if (cl_ps) ns = S2;
                else if (cr_ps) ns = S0;
            end
        endcase
    end
endmodule
