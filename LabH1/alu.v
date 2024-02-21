`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/29 20:15:40
// Design Name: 
// Module Name: alu
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


module alu #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    input [2:0] f,
    output reg [WIDTH-1:0] y,
    output [2:0] t
);
    assign t[0] = (f == 0) ? (a == b) : 0;
    assign t[1] = (f == 0) ?((a[WIDTH-1] == b[WIDTH-1]) ? (a < b) : (a[WIDTH-1] > b[WIDTH-1])) : 0;
    assign t[2] = (f == 0) ? (a < b) : 0;

    always @(*) begin
        y = 0;
        case (f)
            3'd0: y = a - b;
            3'd1: y = a + b;
            3'd2: y = a & b;
            3'd3: y = a | b;
            3'd4: y = a ^ b;
            3'd5: y = a >> b;
            3'd6: y = a << b;
            3'd7: y = $signed(a) >>> b;
        endcase
    end
endmodule
