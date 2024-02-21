`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/09 12:58:59
// Design Name: 
// Module Name: cpu_top_tb
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

//~ `New testbench
`timescale  1ns / 1ps

module cpu_top_tb;

// cpu_top Parameters
parameter PERIOD  = 5;


// cpu_top Inputs
reg   clk                                  = 0;
reg   clk_ld                               = 0;
reg   rstn                                 = 0;
reg   [31:0]  addr                         = 0;
reg   [31:0]  din                          = 0;
reg   we_dm                                = 0;
reg   we_im                                = 0;
reg   debug                                = 0;

// cpu_top Outputs
wire  [31:0]  ir;
wire  [31:0]  ctl;
wire  [31:0]  a;
wire  [31:0]  b;
wire  [31:0]  imm;
wire  [31:0]  y;
wire  [31:0]  mdr                          ;
wire  [31:0]  pc                           ;
wire  [31:0]  npc                          ;
wire  [31:0]  dout_dm                      ;
wire  [31:0]  dout_im                      ;
wire  [31:0]  dout_rf                      ;
wire  [31:0]  cnt_out                      ;
wire          led_out                      ;


initial
begin
    forever #(PERIOD/2)  clk = ~clk;
end

initial
begin
    #(PERIOD*2) rstn = 1;
end

cpu_top  u_cpu_top (
    .clk                     (debug ? 0 : +clk),
    .clk_ld                  (clk_ld),
    .rstn                    (rstn),
    .addr                    (addr[31:0]),
    .din                     (din[31:0]),
    .we_dm                   (we_dm),
    .we_im                   (we_im),
    .debug                   (debug),

    .ir                      (ir       [31:0]),
    .ctl                     (ctl      [31:0]),
    .a                       (a        [31:0]),
    .b                       (b        [31:0]),
    .imm                     (imm      [31:0]),
    .y                       (y        [31:0]),
    .mdr                     (mdr      [31:0]),
    .pc                      (pc       [31:0]),
    .npc                     (npc      [31:0]),
    .dout_dm                 (dout_dm  [31:0]),
    .dout_im                 (dout_im  [31:0]),
    .dout_rf                 (dout_rf  [31:0]),
    .cnt_out                 (cnt_out  [31:0]),
    .led_out                 (led_out        )
);

initial
begin
    #(1000*PERIOD);
end

initial begin
    forever begin
        #PERIOD;
        if (pc == 32'h0000_00c4) begin
            debug = 1;
            addr = addr + 1;
        end
    end
end


endmodule
