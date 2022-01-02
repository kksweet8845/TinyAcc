`timescale 1ns/10ps


module top_tb;


reg clk;
reg rst;
reg start;
wire done;

reg [3:0] row_a, col_b, k;

reg [`GBUFF_ADDR_SIZE-1:0] GOLDEN [`WORD_SIZE-1:0];

always #(`CYCLE/2) clk = ~clk;
















endmodule