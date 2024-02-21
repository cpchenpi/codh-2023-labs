`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 01:26:55
// Design Name: 
// Module Name: dynamic_display
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


module dynamic_display(
    input       clk, rstn,
    input  [31:0] d,
    output [7:0] an,
    output [6:0] cn
);
    frequency_divider #(.WIDTH(32), .k(32'd20_0000)) FRD(.clk(clk), .rstn(rstn), .clk_out(clkd));
    wire [2:0] q;
    counter #(.WIDTH(3)) CNT(.clk(clkd), .rstn(rstn), .pe(1'b0), .ce(1'b1), .d(3'b0), .q(q[2:0]));
    wire [7:0] dcd_out;
    decoder3_8 DCD(.in(q[2:0]), .out(dcd_out[7:0]));
    assign an[7:0] = ~dcd_out[7:0];
    wire [3:0] din;
    selector4_8 SEL(.a0(d[3:0]), .a1(d[7:4]), .a2(d[11:8]), .a3(d[15:12]), .a4(d[19:16]), .a5(d[23:20]), .a6(d[27:24]), .a7(d[31:28]), .sel(q[2:0]), .out(din[3:0]));
    seven_display_decoder SDD(.d(din), .yn(cn));
endmodule


module  counter #(
    parameter   WIDTH = 16, 
              RST_VLU = 0
)(
    input clk, rstn, pe, ce, 
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk, negedge rstn) begin
        if (!rstn)    q <= RST_VLU;
        else if (pe)  q <= d;
        else if (ce)  q <= q - 1; 
    end
endmodule

module frequency_divider #(
    parameter WIDTH = 16, k = 4  
)(
    input      clk, rstn,
    output reg clk_out
    );
    reg [WIDTH - 1: 0] cnt;
    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            cnt <= k - 1;
        else if(cnt == 0)
            cnt <= k - 1;
        else
            cnt <= cnt - 1;
    end
    
    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            clk_out <= 0;
        else
            clk_out <= (cnt > ((k - 1) >> 1));
    end
endmodule

module decoder3_8(
    input      [2:0] in,
    output reg [7:0] out
    );
    always @(*) begin
        out = 8'b0;
        case(in)
        3'd0: out = 8'b0000_0001;
        3'd1: out = 8'b0000_0010;
        3'd2: out = 8'b0000_0100;
        3'd3: out = 8'b0000_1000;
        3'd4: out = 8'b0001_0000;
        3'd5: out = 8'b0010_0000;
        3'd6: out = 8'b0100_0000;
        3'd7: out = 8'b1000_0000;
        endcase
    end
endmodule

module selector4_8(
    input      [3:0] a0, a1, a2, a3, a4, a5, a6, a7,
    input      [2:0] sel,
    output reg [3:0] out
    );
    always @(*) begin
        out = a0;
        case(sel)
        3'd0: out = a0;
        3'd1: out = a1;
        3'd2: out = a2;
        3'd3: out = a3;
        3'd4: out = a4;
        3'd5: out = a5;
        3'd6: out = a6;
        3'd7: out = a7;
        endcase
    end
endmodule

module seven_display_decoder (
    input [3:0] d,
    output reg [6:0] yn
);
    always @(*) begin
        yn = 7'b111_1110;
        case(d)
        4'd0: yn = 7'b000_0001;
        4'd1: yn = 7'b100_1111;
        4'd2: yn = 7'b001_0010;
        4'd3: yn = 7'b000_0110;
        4'd4: yn = 7'b100_1100;
        4'd5: yn = 7'b010_0100;
        4'd6: yn = 7'b010_0000;
        4'd7: yn = 7'b000_1111;
        4'd8: yn = 7'b000_0000;
        4'd9: yn = 7'b000_0100;
        4'ha: yn = 7'b000_1000;
        4'hb: yn = 7'b110_0000;
        4'hc: yn = 7'b011_0001;
        4'hd: yn = 7'b100_0010;
        4'he: yn = 7'b011_0000;
        4'hf: yn = 7'b011_1000;
        endcase
    end
endmodule

