`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/11 11:24:53
// Design Name: 
// Module Name: regfile_tb
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


module regfile_tb();
    reg clk, we;
    reg [4:0] ra1, ra2, wa;
    reg [31:0] wd;
    wire [31:0] rd1, rd2;
    register_file u_register_file(
        .clk (clk),
        .ra1 (ra1),
        .ra2 (ra2),
        .rd1 (rd1),
        .rd2 (rd2),
        .wa  (wa),
        .wd  (wd),
        .we  (we)
    );

initial begin
    clk = 0; 
    forever begin
        #1; clk = ~clk;
    end
end

initial begin
    ra1 = 0;
    ra2 = 1;
    wa = 0;
    we = 0;
    wd = 32'h1145;
    #2;
    we = 1;
    #2;
    we = 0;
    #2;
    wa = 1;
    wd = 32'h1919;
    we = 1;
    #2;
    we = 0;
    #2;
    ra1 = 1;
    ra2 = 2;
    #2;
    we = 1;
    wa = 2;
    wd = 32'h114514;
    #2;
    we = 0;
    #2;
end

endmodule
