`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 19:17:03
// Design Name: 
// Module Name: cpu_top
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


module cpu_top(
    input  clk, rstn, clk_glb,
    input  [31:0] sdu_dm_addr,
    output [31:0] sdu_dm_rdata,
    input  [4:0] sdu_rf_addr,
    output [31:0] sdu_rf_rdata,
    output [31:0] ctl_EX,
    output [31:0] pc_IF, npc_IF, ir_IF,
    output [31:0] pc_ID, ir_ID,
    output [31:0] pc_EX, ir_EX,
    output [31:0] reg_a_EX, reg_b_EX, imm_EX,
    output [31:0] ir_MEM, alu_y_MEM,
    output [31:0] wdata_MEM,
    output [31:0] ir_WB, rdata_WB,
    output [31:0] alu_y_WB,
    output [31:0] wdata_WB,
    input  [15:0] sw,
    input  del_in, sav_in,
    output [15:0] led_out,
    output [7:0] an,
    output [6:0] cn,
    output [31:0] hit_cnt, tot_cnt
    );

    wire alu_to_pc_EX, br_jal_success_EX;

    wire [31:0] alu_y_EX, ra_IF, br_jal_pc_EX;

    wire IF_stall, ID_stall, ID_flush, EX_flush;

    wire MEM_stall, WB_flush;

    assign WB_flush = MEM_stall;

    wire mem_read_EX, jmp_EX;

    hazard_handle hazard_handle(
    	.mem_read_EX (mem_read_EX),
        .EX_rd       (ir_EX[11:7]),
        .ID_rs1      (ir_ID[19:15]),
        .ID_rs2      (ir_ID[24:20]),
        .IF_stall    (IF_stall),
        .ID_stall    (ID_stall),
        .jmp_EX      (jmp_EX),
        .EX_flush    (EX_flush),
        .ID_flush    (ID_flush)
    );
    

    IF IF(
    	.alu_to_pc      (alu_to_pc_EX),
        .br_jal_success (br_jal_success_EX),
        .clk            (clk),
        .rstn           (rstn),
        .stall          (IF_stall || MEM_stall),
        .alu_out        (alu_y_EX),
        .br_jal_pc      (br_jal_pc_EX),
        .ir             (ir_IF),
        .pc             (pc_IF),
        .ra             (ra_IF),
        .npc            (npc_IF)
    );

    assign jmp_EX = br_jal_success_EX || alu_to_pc_EX;

    wire [31:0] ra_ID;

    IF_ID IF_ID(
    	.clk   (clk),
        .rstn  (rstn),
        .stall (ID_stall || MEM_stall),
        .flush (ID_flush && !MEM_stall),
        .ir_IF (ir_IF),
        .pc_IF (pc_IF),
        .ra_IF (ra_IF),
        .ir_ID (ir_ID),
        .pc_ID (pc_ID),
        .ra_ID (ra_ID)
    );

    wire reg_write_WB;

    wire [4:0] waddr_WB;

    wire [31:0] reg_a_ID, reg_b_ID;

    wire [31:0] imm_ID, ctl_ID;

    ID ID(
    	.clk       (clk),
        .reg_write (reg_write_WB),
        .wa        (waddr_WB),
        .wd        (wdata_WB),
        .ir        (ir_ID),
        .ra_sdu    (sdu_rf_addr),
        .reg_a     (reg_a_ID),
        .reg_b     (reg_b_ID),
        .rd_sdu    (sdu_rf_rdata),
        .imm       (imm_ID),
        .ctl       (ctl_ID)
    );

    wire [31:0] ra_EX;

    wire [31:0] reg_a_ID_EX, reg_b_ID_EX;

    ID_EX ID_EX(
    	.clk      (clk),
        .rstn     (rstn),
        .stall    (MEM_stall),
        .flush    (EX_flush && !MEM_stall),
        .ra_ID    (ra_ID),
        .pc_ID    (pc_ID),
        .ra_EX    (ra_EX),
        .pc_EX    (pc_EX),
        .ir_ID    (ir_ID),
        .ir_EX    (ir_EX),
        .reg_a_ID (reg_a_ID),
        .reg_b_ID (reg_b_ID),
        .reg_a_EX (reg_a_ID_EX),
        .reg_b_EX (reg_b_ID_EX),
        .imm_ID   (imm_ID),
        .ctl_ID   (ctl_ID),
        .imm_EX   (imm_EX),
        .ctl_EX   (ctl_EX)
    );

    assign mem_read_EX = ctl_EX[18];

    wire reg_write_MEM;
    wire [1:0] forward_rs1, forward_rs2;

    forwarding_unit FWU (
    	.reg_write_MEM (reg_write_MEM),
        .reg_write_WB  (reg_write_WB),
        .rd_MEM        (ir_MEM[11:7]),
        .rd_WB         (ir_WB[11:7]),
        .rs1_EX        (ir_EX[19:15]),
        .rs2_EX        (ir_EX[24:20]),
        .forward_rs1   (forward_rs1),
        .forward_rs2   (forward_rs2)
    );

    mux3 #(
        .WIDTH (32)
    ) rs1_MUX_EX (
    	.d0  (reg_a_ID_EX),
        .d1  (alu_y_MEM),
        .d2  (wdata_WB),
        .sel (forward_rs1),
        .q   (reg_a_EX)
    );
    
    mux3 #(
        .WIDTH (32)
    ) rs2_MUX_EX (
    	.d0  (reg_b_ID_EX),
        .d1  (alu_y_MEM),
        .d2  (wdata_WB),
        .sel (forward_rs2),
        .q   (reg_b_EX)
    );
    
    EX EX(
    	.reg_a          (reg_a_EX),
        .reg_b          (reg_b_EX),
        .imm            (imm_EX),
        .pc             (pc_EX),
        .ctl            (ctl_EX),
        .alu_y          (alu_y_EX),
        .br_jal_pc      (br_jal_pc_EX),
        .alu_to_pc      (alu_to_pc_EX),
        .br_jal_success (br_jal_success_EX)
    );

    wire [31:0] ra_MEM, ctl_MEM;
    
    EX_MEM EX_MEM(
    	.clk       (clk),
        .rstn      (rstn),
        .stall     (MEM_stall),
        .ir_EX     (ir_EX),
        .ir_MEM    (ir_MEM),
        .reg_b_EX  (reg_b_EX),
        .wd_MEM    (wdata_MEM),
        .alu_y_EX  (alu_y_EX),
        .alu_y_MEM (alu_y_MEM),
        .ra_EX     (ra_EX),
        .ra_MEM    (ra_MEM),
        .ctl_EX    (ctl_EX),
        .ctl_MEM   (ctl_MEM)
    );

    assign reg_write_MEM = ctl_MEM[16];

    wire [31:0] rdata_MEM;
    
    // MEM MEM(
    //     .clk       (clk),
    //     .rstn      (rstn),
    //     .ctl       (ctl_MEM),
    //     .addr      (alu_y_MEM),
    //     .wdata     (wdata_MEM),
    //     .rdata     (rdata_MEM),
    //     .sdu_raddr (sdu_dm_addr),
    //     .sdu_rdata (sdu_dm_rdata),
    //     .led_out   (led_out),
    //     .cnt_out   (cnt_out)
    // );

    wire [31:0] iou_addr, iou_dout, iou_din;
    wire iou_re, iou_we;

    assign sdu_dm_rdata = 0;

    wire mem_done;

    MEM MEM(
    	.clk       (clk),
        .rstn      (rstn),
        .ctl       (ctl_MEM),
        .addr      (alu_y_MEM),
        .wdata     (wdata_MEM),
        .rdata     (rdata_MEM),
        .iou_addr  (iou_addr),
        .iou_dout  (iou_dout),
        .iou_din   (iou_din),
        .iou_re    (iou_re),
        .iou_we    (iou_we),
        .done      (mem_done),
        .hit_cnt   (hit_cnt),
        .tot_cnt   (tot_cnt)
    );
    
    assign MEM_stall = !mem_done;

    wire [31:0] ctl_WB, ra_WB;
    
    MEM_WB MEM_WB(
    	.clk       (clk),
        .rstn      (rstn),
        .flush     (WB_flush),
        .ctl_MEM   (ctl_MEM),
        .ctl_WB    (ctl_WB),
        .ir_MEM    (ir_MEM),
        .ir_WB     (ir_WB),
        .ra_MEM    (ra_MEM),
        .ra_WB     (ra_WB),
        .rdata_MEM (rdata_MEM),
        .rdata_WB  (rdata_WB),
        .alu_y_MEM (alu_y_MEM),
        .alu_y_WB  (alu_y_WB)
    );
    
    WB WB(
    	.ir        (ir_WB),
        .ctl       (ctl_WB),
        .ra        (ra_WB),
        .rdata     (rdata_WB),
        .alu_y     (alu_y_WB),
        .reg_write (reg_write_WB),
        .waddr     (waddr_WB),
        .wdata     (wdata_WB)
    );

    iou IOU(
        .clk_glb (clk_glb),
        .rstn    (rstn),
        .clk_cpu (clk),
        .sw      (sw),
        .del_in  (del_in),
        .sav_in  (sav_in),
        .addr    (iou_addr),
        .din     (iou_din),
        .re      (iou_re),
        .we      (iou_we),
        .dout    (iou_dout),
        .an      (an),
        .cn      (cn),
        .led     (led_out)
    );
    
endmodule
