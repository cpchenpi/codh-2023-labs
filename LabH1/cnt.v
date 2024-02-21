`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/06 14:23:15
// Design Name: 
// Module Name: cnt
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


module cnt(
    input  clk, 
    input  rstn, 
    input  en,
    output cnt_le2
);
    reg [1:0] cnt_cs, cnt_ns;
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            cnt_cs <= 0;
        end
        else
            cnt_cs <= cnt_ns;
    end

    always @(*) begin
        cnt_ns = cnt_cs;
        case (cnt_cs)
            0: if (en) cnt_ns = 1;
            1: if (en) cnt_ns = 2;
            2: if (en) cnt_ns = 3;
        endcase
    end

    assign cnt_le2 = (cnt_cs != 3);
endmodule
