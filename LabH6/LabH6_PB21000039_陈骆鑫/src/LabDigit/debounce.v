`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 01:23:06
// Design Name: 
// Module Name: debounce
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


module debounce(
    input x, clk, rstn,
    output reg y
    );
    parameter times = 2_0000;
    reg st, old_x, old_td;
    timer #(.onesec(times - 1)) TM(.tc(32'd1), .st(st), .clk(clk), .rstn(rstn), .q(), .td(td));
    always @(negedge rstn, posedge clk) begin
        if (!rstn) begin
            y      <= 0;
            st     <= 0;
            old_x  <= 0;
            old_td <= 1;
        end
        else begin
            if ((x & ~old_x) | (old_x & ~x)) begin
                if (td)
                    st <= 1;
                old_x <= x;
            end
            if ((td & ~old_td) | (~td & old_td)) begin
                if (td) begin
                    st <= 0;
                    if (x == ~y)
                        y <= ~y;
                end
                old_td <= td;
            end
        end
    end
endmodule

module timer #(
    parameter WIDTH  = 16,
              onesec = 32'd100_000_000
)(
        input [WIDTH - 1:0] tc,
        input st, rstn, clk,
        output reg [WIDTH - 1:0] q,
        output reg td
    );
    reg [31:0] cnt;
    reg old_st;
    always @(negedge rstn, posedge clk) begin
        if (!rstn) begin
            q <= 0;
            td <= 1;
            cnt <= 0;
            old_st <= 0;
        end
        else if (clk) begin
            if (st & ~old_st) begin
                if (tc) begin
                    q <= tc;
                    cnt <= onesec - 1;
                    td <= 0;
                end
                else begin
                    q <= 0;
                    cnt <= onesec - 1;
                    td <= 1;
                end
            end
            else if(!td) begin
                if (!cnt) begin
                    cnt <= onesec - 1;
                    if (q == 1'b1)
                        td <= 1;
                    q <= q - 1;
                end
                else begin
                    cnt <= cnt - 1;
                end
            end
            old_st <= st;
        end
    end
endmodule