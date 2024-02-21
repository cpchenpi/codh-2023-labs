`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/11 16:00:17
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    input  clk, rstn, run,
    input  loop_bound, rev_order, flag_out,
    output reg sel_dpra, en_n,
    output reg en_flag, flag_in,
    output reg en_i, sel_i,
    output reg sel_a,
    output reg en_p, en_q,
    output reg sel_d,
    output reg srt_we,
    output reg done_rev
    );

    reg [2:0] cs, ns;

    parameter S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4, S5 = 3'd5, S6 = 3'd6, S7 = 3'd7;

    always @(posedge clk, negedge rstn) begin
        if (!rstn) cs <= S0;
        else cs <= ns;
    end

    always @(*) begin
        ns = cs;
        sel_dpra = 0; en_n = 0;
        en_flag = 0; flag_in = 0;
        en_i = 0; sel_i = 0;
        sel_a = 0;
        en_p = 0; en_q = 0;
        sel_d = 0;
        srt_we = 0;
        done_rev = 0;
        case (cs) 
            S0: begin
                if (run) begin
                    ns = S1;
                end
                else ns = S0;
            end

            S1: begin
                done_rev = 1;
                ns = S2;
            end

            S2: begin
                en_flag = 1; flag_in = 0;
                en_i = 1; sel_i = 0;    // i = 1
                sel_dpra = 1; en_n = 1; // n = mem[0]
                ns = S3;
            end

            S3: begin
                sel_a = 0; sel_dpra = 0; // i and i + 1
                en_p = 1; en_q = 1;
                ns = S4;
            end

            S4: begin
                if (rev_order) begin
                    en_flag = 1; flag_in = 1;
                end
                sel_a = 0; sel_d = 1; // mem[i] = q
                srt_we = rev_order;
                ns = S5;
            end

            S5: begin
                sel_a = 1; sel_d = 0; // mem[i + 1] = p
                srt_we = rev_order;
                ns = S6;
            end

            S6: begin
                en_i = 1; sel_i = 1;
                if (loop_bound) begin
                    if (flag_out) ns = S2;
                    else ns = S7;
                end
                else ns = S3;
            end

            S7: begin
                done_rev = 1;
                ns = S0;
            end
        endcase
    end
endmodule
