`include "define.v"
module Decoder(
    instr_valid,
    instr,
    valid,
    op,
    WB_src_addr,
    WB_channel,
    WB_row,
    WB_col,
    A_src_addr,
    A_channel,
    A_row,
    A_col,
    B_src_addr,
    B_channel,
    B_row,
    B_col
);

input                               instr_valid;
input [104:0]                       instr;

output                              valid;
output     [2:0]                    op;
output     [`WORD_ADDR_BITS-1:0]    WB_src_addr;
output     [`DATA_MAX_BITS-1:0]     WB_channel;
output     [`DATA_MAX_BITS-1:0]     WB_row;
output     [`DATA_MAX_BITS-1:0]     WB_col;
output     [`WORD_ADDR_BITS-1:0]    A_src_addr;
output     [`DATA_MAX_BITS-1:0]     A_channel;
output     [`DATA_MAX_BITS-1:0]     A_row;
output     [`DATA_MAX_BITS-1:0]     A_col;
output     [`WORD_ADDR_BITS-1:0]    B_src_addr;
output     [`DATA_MAX_BITS-1:0]     B_channel;
output     [`DATA_MAX_BITS-1:0]     B_row;
output     [`DATA_MAX_BITS-1:0]     B_col;



assign valid        = instr_valid;
assign op           = instr[104:102];
assign WB_src_addr  = instr[101:92];
assign WB_channel   = instr[91:84];
assign WB_row       = instr[83:76];
assign WB_col       = instr[75:68];
assign A_src_addr   = instr[67:58];
assign A_channel    = instr[57:50];
assign A_row        = instr[49:42];
assign A_col        = instr[41:34];
assign B_src_addr   = instr[33:24];
assign B_channel    = instr[23:16];
assign B_row        = instr[15:8];
assign B_col        = instr[7:0];


endmodule

