`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 20:41:16
// Design Name: 
// Module Name: MEM
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


module MEM(
    input  clk, rstn,
    input  [31:0] ctl,
    input  [31:0] addr, wdata,
    output [31:0] rdata,
    output [31:0] iou_addr,
    input  [31:0] iou_dout,
    output [31:0] iou_din,
    output iou_re, iou_we, done,
    output [31:0] hit_cnt, tot_cnt
    );

    wire mem_read, mem_write;
    assign mem_read = ctl[18], mem_write = ctl[17];

    wire chip_select;

    localparam CHIP_DMEM = 1'b0, CHIP_IO = 1'b1;

    // 0x2000 - 0x2ffc => [15:12] == 0x2
    assign chip_select = (addr[31:12] == 'h2) ? CHIP_DMEM : CHIP_IO;

    wire dm_re, dm_we;
    assign  iou_re = (chip_select == CHIP_IO && mem_read), iou_we = (chip_select == CHIP_IO && mem_write),
            dm_re = (chip_select == CHIP_DMEM && mem_read), dm_we = (chip_select == CHIP_DMEM && mem_write);

    wire [31:0] dm_rdata;
    wire done_dmem;

    cache DCACHE(
    	.addr       (addr),
        .din        (wdata),
        .clk        (clk),
        .rstn       (rstn),
        .re         (mem_read && (chip_select == CHIP_DMEM)),
        .we         (mem_write && (chip_select == CHIP_DMEM)),
        .done       (done_dmem),
        .dout       (dm_rdata),
        .hit_cnt    (hit_cnt),
        .tot_cnt    (tot_cnt)
    );

    // cache_direct DCACHE(
    // 	.addr       (addr),
    //     .din        (wdata),
    //     .clk        (clk),
    //     .rstn       (rstn),
    //     .re         (mem_read && (chip_select == CHIP_DMEM)),
    //     .we         (mem_write && (chip_select == CHIP_DMEM)),
    //     .done       (done_dmem),
    //     .dout       (dm_rdata),
    //     .hit_cnt    (hit_cnt),
    //     .tot_cnt    (tot_cnt)
    // );

    assign iou_din = wdata, iou_addr = addr;
    assign rdata = (chip_select == CHIP_DMEM) ? dm_rdata : iou_dout;
    assign done = (chip_select == CHIP_DMEM) ? done_dmem : 1;

endmodule
