`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 18:49:28
// Design Name: 
// Module Name: cache_direct_way
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


module cache_direct_way(
    input [31:0] addr, din, 
    input [255:0] blk_in,
    input clk, rstn, re, we,
    input done, blk_write,
    output hit, dirty,
    output reg [31:0] dout,
    output [31:0] orig_addr,
    output [255:0] blk_out
);
    
    // [255:0] datas (8 words, 32 bit per word)
    // [277:256] tag
    // [278] dirty bit
    // [279] valid bit

    wire [21:0] tag = addr[31:10];
    wire [4:0] index = addr[9:5];
    wire [2:0] offset = addr[4:2]; // word offset

    reg  [279:0] cmem_din;
    reg cmem_we;
    wire [279:0] cmem_dout;
    assign blk_out = cmem_dout[255:0];

    CMem_direct CMEM (
        .a(index),          // input wire [4 : 0] a
        .d(cmem_din),       // input wire [279 : 0] d
        .clk(clk),          // input wire clk
        .we(cmem_we),       // input wire we
        .spo(cmem_dout)     // output wire [279 : 0] spo
    );

    assign hit = (cmem_dout[277:256] == tag) && cmem_dout[279];
    assign dirty = cmem_dout[279] && cmem_dout[278];

    assign orig_addr = {cmem_dout[277:256], index, 5'b0};

    always @(*) begin
        case (offset)
            0: dout = blk_out[31:0];
            1: dout = blk_out[63:32];
            2: dout = blk_out[95:64];
            3: dout = blk_out[127:96];
            4: dout = blk_out[159:128];
            5: dout = blk_out[191:160];
            6: dout = blk_out[223:192];
            7: dout = blk_out[255:224];
        endcase
    end

    always @(*) begin
        cmem_din = 0;
        cmem_we = 0;
        if (done) begin
            if (we) begin
                cmem_we = 1;
                // write and set dirty bit
                // (we know it should be valid)
                case (offset)
                    0: cmem_din = {2'b11, cmem_dout[277:32], din[31:0]};
                    1: cmem_din = {2'b11, cmem_dout[277:64], din[31:0], cmem_dout[31:0]};
                    2: cmem_din = {2'b11, cmem_dout[277:96], din[31:0], cmem_dout[63:0]};
                    3: cmem_din = {2'b11, cmem_dout[277:128], din[31:0], cmem_dout[95:0]};
                    4: cmem_din = {2'b11, cmem_dout[277:160], din[31:0], cmem_dout[127:0]};
                    5: cmem_din = {2'b11, cmem_dout[277:192], din[31:0], cmem_dout[159:0]};
                    6: cmem_din = {2'b11, cmem_dout[277:224], din[31:0], cmem_dout[191:0]};
                    7: cmem_din = {2'b11, cmem_dout[277:256], din[31:0], cmem_dout[223:0]};
                endcase
            end
        end else begin
            if (blk_write) begin
                cmem_we = 1;
                // valid, not dirty
                cmem_din = {2'b10, tag[21:0], blk_in[255:0]};
            end
        end
    end
endmodule