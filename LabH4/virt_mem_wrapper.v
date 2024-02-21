`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/09 21:28:46
// Design Name: 
// Module Name: virt_mem_wrapper
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


module virt_mem_wrapper(
    input [31:0] addr, din,
    input clk, we, rstn, clk_cpu, 
    output reg [31:0] dout,
    output led_out,
    output [31:0] cnt_out
    );

    reg [1:0] chip_select;
    parameter CHIP_DM = 2'b00, CHIP_LED = 2'b01, CHIP_CNT = 2'b10, CHIP_DFT = 2'b11;
    parameter ADDR_LED = 32'h7f00, ADDR_CNT = 32'h7f20;
    always @(*) begin
        chip_select = CHIP_DFT;
        if (addr >= 32'h2000 && addr <= 32'h2ffc) chip_select = CHIP_DM;
        else if (addr == ADDR_LED) chip_select = CHIP_LED;
        else if (addr == ADDR_CNT) chip_select = CHIP_CNT;
    end

    wire [31:0] dm_out;
    dist_data_mem data_mem (
        .a(addr[11:2]),                         // input wire [9:0] a
        .d(din),                                // input wire [31:0] d
        .clk(clk),                              // input wire clk
        .we((chip_select == CHIP_DM) && we),    // input wire we
        .spo(dm_out)                            // output wire [31:0] spo
    );

    register #(.WIDTH (1)) LED(
    	.clk  (clk),
        .rstn (rstn),
        .en   ((chip_select == CHIP_LED) && we),
        .d    (din[0]),
        .q    (led_out)
    );
    
    register #(.WIDTH (32)) CNT(
    	.clk  (clk_cpu),
        .rstn (rstn),
        .en   (1'b1),
        .d    (cnt_out + 1),
        .q    (cnt_out)
    );

    always @(*) begin
        case (chip_select)
            CHIP_DM: dout = dm_out;
            CHIP_LED: dout = {31'b0, led_out};
            CHIP_CNT: dout = cnt_out;
            default: dout = 0;
        endcase
    end

endmodule
