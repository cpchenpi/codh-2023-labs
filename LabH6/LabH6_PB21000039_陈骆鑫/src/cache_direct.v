`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 18:44:18
// Design Name: 
// Module Name: cache_direct
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


module cache_direct(
    input  [31:0] addr,
    input  [31:0] din,
    input  clk, rstn, re, we,
    output done,
    output [31:0] dout,
    output [31:0] hit_cnt, tot_cnt
    );

    wire [31:0] orig_addr;
    reg [31:0] dmem_addr;
    reg [31:0] dmem_din;
    reg dmem_we;
    wire [31:0] dmem_dout;

    bram DMEM(
    	.clk  (clk),
        .addr (dmem_addr[11:2]),
        .din  (dmem_din),
        .we   (dmem_we),
        .dout (dmem_dout)
    );

    reg [255:0] tmp_in; reg set_tmp;
    wire [255:0] tmp_out;

    register #(
        .WIDTH (256)
    ) REG_TMP(
    	.clk  (clk),
        .rstn (rstn),
        .en   (set_tmp),
        .d    (tmp_in),
        .q    (tmp_out)
    );

    wire [255:0] blk_out;
    reg blk_write;

    cache_direct_way WAY(
    	.addr      (addr),
        .din       (din),
        .blk_in    (tmp_in),
        .clk       (clk),
        .rstn      (rstn),
        .re        (re),
        .we        (we),
        .done      (done),
        .blk_write (blk_write),
        .hit       (hit),
        .dirty     (dirty),
        .dout      (dout),
        .orig_addr (orig_addr),
        .blk_out   (blk_out)
    );

    reg [5:0] cs, ns;

    always @(posedge clk, negedge rstn) begin
        if (!rstn) cs <= 0;
        else cs <= ns;
    end

    assign done = (cs == 0) && (ns == 0);
    
    always @(*) begin
        ns = cs + 1;
        dmem_addr = 0;
        dmem_din = 0; dmem_we = 0;
        set_tmp = 0; tmp_in = 0;
        blk_write = 0;
        case (cs)
            0: begin
                if (!(re || we))
                    ns = 0;
                else begin
                    if (hit) ns = 0;
                    else ns = 1;
                end
            end
            16: begin
                if (dirty) ns = 17;
                else ns = 25;
            end


            17: begin
                dmem_addr = {orig_addr[31:5], 5'd0};
                dmem_din = blk_out[31:0];
                dmem_we = 1;
            end
            18: begin
                dmem_addr = {orig_addr[31:5], 5'd4};
                dmem_din = blk_out[63:32];
                dmem_we = 1;
            end
            19: begin
                dmem_addr = {orig_addr[31:5], 5'd8};
                dmem_din = blk_out[95:64];
                dmem_we = 1;
            end
            20: begin
                dmem_addr = {orig_addr[31:5], 5'd12};
                dmem_din = blk_out[127:96];
                dmem_we = 1;
            end
            21: begin
                dmem_addr = {orig_addr[31:5], 5'd16};
                dmem_din = blk_out[159:128];
                dmem_we = 1;
            end
            22: begin
                dmem_addr = {orig_addr[31:5], 5'd20};
                dmem_din = blk_out[191:160];
                dmem_we = 1;
            end
            23: begin
                dmem_addr = {orig_addr[31:5], 5'd24};
                dmem_din = blk_out[223:192];
                dmem_we = 1;
            end
            24: begin
                dmem_addr = {orig_addr[31:5], 5'd28};
                dmem_din = blk_out[255:224];
                dmem_we = 1;
            end


            25: begin
                dmem_addr = {addr[31:5], 5'd0};
            end
            26: begin
                dmem_addr = {addr[31:5], 5'd4};
                tmp_in = {tmp_out[255:32], dmem_dout[31:0]};
                set_tmp = 1;
            end
            27: begin
                dmem_addr = {addr[31:5], 5'd8};
                tmp_in = {tmp_out[255:64], dmem_dout[31:0], tmp_out[31:0]};
                set_tmp = 1;
            end
            28: begin
                dmem_addr = {addr[31:5], 5'd12};
                tmp_in = {tmp_out[255:96], dmem_dout[31:0], tmp_out[63:0]};
                set_tmp = 1;
            end
            29: begin
                dmem_addr = {addr[31:5], 5'd16};
                tmp_in = {tmp_out[255:128], dmem_dout[31:0], tmp_out[95:0]};
                set_tmp = 1;
            end
            30: begin
                dmem_addr = {addr[31:5], 5'd20};
                tmp_in = {tmp_out[255:160], dmem_dout[31:0], tmp_out[127:0]};
                set_tmp = 1;
            end
            31: begin
                dmem_addr = {addr[31:5], 5'd24};
                tmp_in = {tmp_out[255:192], dmem_dout[31:0], tmp_out[159:0]};
                set_tmp = 1;
            end
            32: begin
                dmem_addr = {addr[31:5], 5'd28};
                tmp_in = {tmp_out[255:224], dmem_dout[31:0], tmp_out[191:0]};
                set_tmp = 1;
            end
            33: begin
                ns = 0;
                tmp_in = {dmem_dout[31:0], tmp_out[223:0]};
                blk_write = 1;
            end
            
            default: ns = cs + 1;
        endcase
    end
    
    // every data access will done eventually

    register #(
        .WIDTH (32)
    ) REG_TOT (
    	.clk  (clk),
        .rstn (rstn),
        .en   ((re || we) && done),
        .d    (tot_cnt + 1),
        .q    (tot_cnt)
    );

    // have been to state 1 means not hit

    wire [31:0] nhit_cnt;

    register #(
        .WIDTH (32)
    ) REG_NHIT (
    	.clk  (clk),
        .rstn (rstn),
        .en   (cs == 1),
        .d    (nhit_cnt + 1),
        .q    (nhit_cnt)
    );
    
    assign hit_cnt = tot_cnt - nhit_cnt;

endmodule
