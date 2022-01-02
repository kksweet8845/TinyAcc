module ctrl(
    input           clk,
    input           reset,
    //* unified buffer
    input           uni_ready,
    input           uni_busy,
    output          uni_load,
    output          uni_type,
    output  [31:0]  uni_init_addr,
    output  [9:0]   uni_col,
    output  [9:0]   uni_row,
    output  [31:0]  uni_out_addr,

    //* weighting buffer
    input           wei_ready,
    input           wei_busy,
    output          wei_load,
    output          wei_k0_init_addr,
    output



);



endmodule