`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/12 13:57:25
// Design Name: 
// Module Name: iou
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


module iou(
    input  clk_glb, rstn, clk_cpu,
    input  [15:0] sw,
    input  del_in, sav_in,
    input  [31:0] addr,
    input  [31:0] din,
    input  re, we,
    output reg [31:0] dout,
    output [7:0] an,
    output [6:0] cn,
    output [15:0] led
    );
    localparam  led_data_addr = 32'h7f00, seg_rdy_addr = 32'h7f04, seg_data_addr = 32'h7f08,
                swx_vld_addr = 32'h7f0C, swx_data_addr = 32'h7f10, cnt_data_addr = 32'h7f14;
    
    reg seg_rdy, swx_vld;
    reg [15:0] led_data;
    reg [31:0] cnt_data;

    // input preprocess begin

    wire del_db, sav_db, del, sav;

    assign del_db = del_in, sav_db = sav_in; // for test

    // debounce DEL_DB (
    //     .x    (del_in),
    //     .clk  (clk_glb),
    //     .rstn (rstn),
    //     .y    (del_db)
    // );

    // debounce SAV_DB (
    //     .x    (sav_in),
    //     .clk  (clk_glb),
    //     .rstn (rstn),
    //     .y    (sav_db)
    // );

    take_posedge #(
        .WIDTH (2)
    ) DEL_SAV_PS (
    	.x    ({del_db, sav_db}),
        .clk  (clk_glb),
        .rstn (rstn),
        .y    ({del, sav})
    );
    
    // input preprocess end

    // swx part begin

    reg [31:0] tmp, swx_data;

    wire [15:0] sw_ps;
    wire swf;
    wire [3:0]  swe;

    take_posedge #(
        .WIDTH (16)
    ) SW_PS(
    	.x    (sw),
        .clk  (clk_glb),
        .rstn (rstn),
        .y    (sw_ps)
    );

    encoder16_4 SW_ECD(
    	.in  (sw_ps),
        .f   (swf),
        .out (swe)
    );

    always @(posedge clk_glb, negedge rstn) begin
        if (!rstn) begin
            tmp <= 0;
            swx_data <= 0;
            swx_vld <= 0;
        end
        else begin
            if (del) tmp <= {4'b0, tmp[31:4]};
            else if (swf) tmp <= {tmp[27:0], swe};
            if (sav) begin
                swx_vld <= 1;
                swx_data <= tmp;
                tmp <= 0;
            end 
            else if (addr == swx_data_addr && re) begin
                swx_vld <= 0;
            end
        end
    end

    // swx part end

    // seg part begin

    reg [31:0] seg_data;
    wire [31:0] disp_data;

    dynamic_display u_dynamic_display(
    	.clk  (clk_glb),
        .rstn (rstn),
        .d    (disp_data),
        .an   (an),
        .cn   (cn)
    );

    always @(posedge clk_glb, negedge rstn) begin
        if (!rstn) begin
            seg_rdy <= 1;
        end
        else begin
            if (addr == seg_data_addr && we) begin
                seg_rdy <= 0;
            end else if (swf || del) begin
                seg_rdy <= 1;
            end
        end
    end

    assign disp_data = seg_rdy ? tmp : seg_data;

    // seg part end

    // read process begin
    always @(*) begin
        case (addr)
            seg_rdy_addr: dout = {31'b0, seg_rdy};
            swx_vld_addr: dout = {31'b0, swx_vld};
            swx_data_addr: dout = swx_data;
            cnt_data_addr: dout = cnt_data;
            default: dout = 0;
        endcase
    end
    // read process end

    // write process begin
        always @(posedge clk_cpu, negedge rstn) begin
            if (!rstn) begin
                led_data <= 0;
                seg_data <= 0;
                cnt_data <= 0;
            end else begin
                if (we) begin
                    case (addr)
                        led_data_addr: led_data <= {din[15:0]};
                        seg_data_addr: seg_data <= din;
                    endcase
                end
                cnt_data <= cnt_data + 1;
            end
        end
    // write process begin

    assign led = led_data;
    
endmodule

module encoder16_4(
    input     [15:0] in,
    output reg       f,
    output reg [3:0] out
    );
    always @(*) begin
        out = 4'b0;
        f = 1'b1;
        if (in[15]) out = 4'd15;
        else if (in[14]) out = 4'd14;
        else if (in[13]) out = 4'd13;
        else if (in[12]) out = 4'd12;
        else if (in[11]) out = 4'd11;
        else if (in[10]) out = 4'd10;
        else if (in[9]) out = 4'd9;
        else if (in[8]) out = 4'd8;
        else if (in[7]) out = 4'd7;
        else if (in[6]) out = 4'd6;
        else if (in[5]) out = 4'd5;
        else if (in[4]) out = 4'd4;
        else if (in[3]) out = 4'd3;
        else if (in[2]) out = 4'd2;
        else if (in[1]) out = 4'd1;
        else if (in[0]) out = 4'd0;
        else f = 1'b0;
    end
endmodule
