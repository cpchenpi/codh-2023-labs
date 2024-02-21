`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/12 17:01:01
// Design Name: 
// Module Name: cache
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


module cache (
    input  [31:0] addr,
    input  [31:0] din,
    input  clk, rstn, re, we,
    output done,
    output [31:0] dout,
    output [31:0] hit_cnt, tot_cnt
    );

    reg [31:0] dmem_addr, dmem_din;
    reg dmem_we;
    wire [31:0] dmem_dout;

    reg [127:0] cache_blk_in;

    bram DMEM(
    	.clk  (clk),
        .addr (dmem_addr[11:2]),
        .din  (dmem_din),
        .we   (dmem_we),
        .dout (dmem_dout)
    );

    wire hit0, access0, dirty0, hit1, access1, dirty1;
    wire [31:0] dout0, dout1;
    wire [31:0] orig_addr0, orig_addr1;
    wire [127:0] blk_out0, blk_out1;
    reg blk_write0, blk_write1;

    cache_block CBLK0(
    	.addr      (addr),
        .din       (din),
        .blk_in    (cache_blk_in),
        .clk       (clk),
        .rstn      (rstn),
        .re        (re),
        .we        (we),
        .done      (done),
        .blk_write (blk_write0),
        .hit       (hit0),
        .access    (access0),
        .dirty     (dirty0),
        .dout      (dout0),
        .blk_out   (blk_out0),
        .orig_addr (orig_addr0)
    );

    cache_block CBLK1(
    	.addr      (addr),
        .din       (din),
        .blk_in    (cache_blk_in),
        .clk       (clk),
        .rstn      (rstn),
        .re        (re),
        .we        (we),
        .done      (done),
        .blk_write (blk_write1),
        .hit       (hit1),
        .access    (access1),
        .dirty     (dirty1),
        .dout      (dout1),
        .blk_out   (blk_out1),
        .orig_addr (orig_addr1)
    );

    assign dout = hit0 ? dout0 : dout1;
    
    reg [4:0] cs, ns;

    assign done = (cs == 0) && (ns == 0);

    always @(posedge clk, negedge rstn) begin
        if (!rstn) cs <= 0;
        else cs <= ns;
    end

    reg replace_in, set_replace;

    wire replace;

    register #(
        .WIDTH (1)
    ) REG_REP(
    	.clk  (clk),
        .rstn (rstn),
        .en   (set_replace),
        .d    (replace_in),
        .q    (replace)
    );

    reg [127:0] tmp_in; reg set_tmp;
    wire [127:0] tmp_out;

    register #(
        .WIDTH (128)
    ) REG_TMP(
    	.clk  (clk),
        .rstn (rstn),
        .en   (set_tmp),
        .d    (tmp_in),
        .q    (tmp_out)
    );
    
    

    always @(*) begin
        ns = cs + 1;
        set_replace = 0; replace_in = 0;
        dmem_addr = 0; dmem_din = 0;
        dmem_we = 0; 
        set_tmp = 0; tmp_in = 0;
        cache_blk_in = 0; blk_write0 = 0; blk_write1 = 0;
        case (cs)
            0: begin
                if (!(re || we))
                    ns = 0;
                else begin
                    if (hit0 || hit1)
                        ns = 0;
                    else ns = 1;
                end
            end
            16: begin
                set_replace = 1;
                if (!access0) begin
                    replace_in = 0;
                    if (dirty0) ns = 17;
                    else ns = 21;
                end
                else begin
                    replace_in = 1;
                    if (dirty1) ns = 17;
                    else ns = 21;
                end
            end
            17: begin
                if (replace == 0) begin
                    dmem_addr = {orig_addr0[31:4], 4'd0};
                    dmem_din = blk_out0[31:0];
                    dmem_we = 1;
                end
                else begin
                    dmem_addr = {orig_addr1[31:4], 4'd0};
                    dmem_din = blk_out1[31:0];
                    dmem_we = 1;
                end
                ns = 18;
            end
            18: begin
                if (replace == 0) begin
                    dmem_addr = {orig_addr0[31:4], 4'd4};
                    dmem_din = blk_out0[63:32];
                    dmem_we = 1;
                end
                else begin
                    dmem_addr = {orig_addr1[31:4], 4'd4};
                    dmem_din = blk_out1[63:32];
                    dmem_we = 1;
                end
                ns = 19;
            end
            19: begin
                if (replace == 0) begin
                    dmem_addr = {orig_addr0[31:4], 4'd8};
                    dmem_din = blk_out0[95:64];
                    dmem_we = 1;
                end
                else begin
                    dmem_addr = {orig_addr1[31:4], 4'd8};
                    dmem_din = blk_out1[95:64];
                    dmem_we = 1;
                end
                ns = 20;
            end
            20: begin
                if (replace == 0) begin
                    dmem_addr = {orig_addr0[31:4], 4'd12};
                    dmem_din = blk_out0[127:96];
                    dmem_we = 1;
                end
                else begin
                    dmem_addr = {orig_addr1[31:4], 4'd12};
                    dmem_din = blk_out1[127:96];
                    dmem_we = 1;
                end
                ns = 21;
            end

            21: begin
                dmem_addr = {addr[31:4], 4'd0};
                dmem_we = 0;
                ns = 22;
            end
            22: begin
                dmem_addr = {addr[31:4], 4'd4};
                dmem_we = 0;
                tmp_in = {tmp_out[127:32], dmem_dout[31:0]};
                set_tmp = 1;
                ns = 23;
            end
            23: begin
                dmem_addr = {addr[31:4], 4'd8};
                dmem_we = 0;
                tmp_in = {tmp_out[127:64], dmem_dout[31:0], tmp_out[31:0]};
                set_tmp = 1;
                ns = 24;
            end
            24: begin
                dmem_addr = {addr[31:4], 4'd12};
                dmem_we = 0;
                tmp_in = {tmp_out[127:96], dmem_dout[31:0], tmp_out[63:0]};
                set_tmp = 1;
                ns = 25;
            end
            25: begin
                ns = 0;
                tmp_in = {dmem_dout[31:0], tmp_out[95:0]};
                cache_blk_in = tmp_in;
                if (replace == 0) begin
                    blk_write0 = 1;
                end
                else begin
                    blk_write1 = 1;
                end
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