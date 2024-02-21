`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/11 16:42:37
// Design Name: 
// Module Name: cycle_counter
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


module cycle_counter(
    input clk, rstn,
    input done,
    output [15:0] cycles
    );
    reg ls_done;
    reg [23:0] cnt;
    assign cycles = cnt[23:8];
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            cnt <= 0;
            ls_done <= 1;
        end
        else begin
            ls_done <= done;
            if (~done) begin
                if (ls_done) cnt <= 1;
                else cnt <= cnt + 1;
            end
        end
    end
endmodule
