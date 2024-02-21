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
    input  [31:0] sdu_raddr,
    output [31:0] sdu_rdata,
    output led_out,
    output [31:0] cnt_out
    );

    wire mem_read, mem_write;
    assign mem_read = ctl[18], mem_write = ctl[17];

    reg [1:0] chip_select;
    localparam CHIP_DM = 2'b00, CHIP_LED = 2'b01, CHIP_CNT = 2'b10;
    localparam ADDR_LED = 32'h7f00, ADDR_CNT = 32'h7f20;
    always @(*) begin
        if (addr == ADDR_LED) chip_select = CHIP_LED;
        else if (addr == ADDR_CNT) chip_select = CHIP_CNT;
        else chip_select = CHIP_DM;
    end

    wire [31:0] dm_rdata, cnt_rdata;
    wire led_rdata;

    wire dm_we;
    assign dm_we = mem_write && (chip_select == CHIP_DM);

    data_mem DM (
        .a(addr[11:2]),     // input wire [9:0] a
        .d(wdata),          // input wire [31:0] d
        .dpra(sdu_raddr[9:0]),    // input wire [9:0] dpra
        .clk(clk),          // input wire clk
        .we(dm_we),         // input wire we
        .spo(dm_rdata),     // output wire [31:0] spo
        .dpo(sdu_rdata)     // output wire [31:0] dpo
    );

    register #(.WIDTH (1)) LED(
    	.clk  (clk),
        .rstn (rstn),
        .en   (mem_write && (chip_select == CHIP_LED)),
        .d    (wdata[0]),
        .q    (led_rdata)
    );

    wire cnt_we;
    assign cnt_we = mem_write && (chip_select == CHIP_CNT);

    register #(.WIDTH (32)) CNT(
    	.clk  (clk),
        .rstn (rstn),
        .en   (1'b1),
        .d    (cnt_we ? wdata : cnt_rdata + 1),
        .q    (cnt_rdata)
    );

    assign rdata = (chip_select == CHIP_LED) ? ({31'b0, led_rdata}) : ((chip_select == CHIP_CNT) ? cnt_rdata : dm_rdata);

    assign led_out = led_rdata;
    assign cnt_out = cnt_rdata;

endmodule
