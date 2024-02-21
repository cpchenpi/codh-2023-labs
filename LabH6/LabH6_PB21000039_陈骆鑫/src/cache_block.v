`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/12 20:53:31
// Design Name: 
// Module Name: cache_block
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


module cache_block (
    input [31:0] addr, din, 
    input [127:0] blk_in,
    input clk, rstn, re, we,
    input done, blk_write,
    output hit, access, dirty,
    output reg [31:0] dout,
    output [31:0] orig_addr,
    output [127:0] blk_out
);
    
    // [127:0] datas (4 words, 32 bit per word)
    // [150:128] tag
    // [151] access bit
    // [152] dirty bit
    // [153] valid bit

    wire [22:0] tag = addr[31:9];
    wire [4:0] index = addr[8:4];
    wire [1:0] offset = addr[3:2]; // word offset

    reg  [153:0] cmem_din;
    reg cmem_we;
    wire [153:0] cmem_dout;
    assign blk_out = cmem_dout[127:0];

    CMem CMEM (
        .a(index),          // input wire [4 : 0] a
        .d(cmem_din),       // input wire [153 : 0] d
        .clk(clk),          // input wire clk
        .we(cmem_we),       // input wire we
        .spo(cmem_dout)     // output wire [153 : 0] spo
    );

    assign hit = (cmem_dout[150:128] == tag) && cmem_dout[153];
    assign access = cmem_dout[153] && cmem_dout[151];
    assign dirty = cmem_dout[153] && cmem_dout[152];

    assign orig_addr = {cmem_dout[150:128], index, 4'b0};

    always @(*) begin
        case (offset)
            0: dout = blk_out[31:0];
            1: dout = blk_out[63:32];
            2: dout = blk_out[95:64];
            3: dout = blk_out[127:96];
        endcase
    end

    always @(*) begin
        cmem_din = 0;
        cmem_we = 0;
        if (done) begin
            if (hit) begin
                if (we) begin
                    cmem_we = 1;
                    // write and set dirty bit / access bit
                    // (we know it should be valid)
                    case (offset)
                        0: cmem_din = {3'b111, cmem_dout[150:32], din[31:0]};
                        1: cmem_din = {3'b111, cmem_dout[150:64], din[31:0], cmem_dout[31:0]};
                        2: cmem_din = {3'b111, cmem_dout[150:96], din[31:0], cmem_dout[63:0]};
                        3: cmem_din = {3'b111, cmem_dout[150:128], din[31:0], cmem_dout[95:0]};
                    endcase
                end else begin
                    cmem_we = 1;
                    // set access bit
                    cmem_din = {cmem_dout[153:152], 1'b1, cmem_dout[150:0]};
                end
            end else begin
                cmem_we = 1;
                // not hit, clear access bit
                cmem_din = {cmem_dout[153:152], 1'b0, cmem_dout[150:0]};
            end
        end else begin
            if (blk_write) begin
                cmem_we = 1;
                // valid, not dirty, not accessed yet
                cmem_din = {3'b100, tag[22:0], blk_in[127:0]};
            end
        end
    end
endmodule