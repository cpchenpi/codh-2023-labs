`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/03 23:53:41
// Design Name: 
// Module Name: cu
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


module cu(
    input clk, rstn, en,
    output reg sel_alu_b,
    output reg en_mis, en_sum3,
    output reg [2:0] f
);
    
    reg cs, ns;
    parameter S0 = 1'd0, S1 = 1'd1;
    parameter f_sub = 3'd0, f_add = 3'd1;

    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            cs <= 0;
        end
        else cs <= ns;
    end

    always @(*) begin
        ns = cs;
        sel_alu_b = 0;
        en_mis = 0; en_sum3 = 0;
        f = 0;
        case(cs) 
            S0: begin
                sel_alu_b = 0; f = f_add; // sum3 + d
                if (en) begin
                    en_sum3 = 1;
                    ns = S1;
                end
                else ns = S0;
            end

            S1: begin
                sel_alu_b = 1; f = f_sub; // sum3 - mi3
                en_sum3 = 1;
                en_mis = 1; // shift mi1 to mi3
                ns = S0;
            end
        endcase
    end
endmodule
