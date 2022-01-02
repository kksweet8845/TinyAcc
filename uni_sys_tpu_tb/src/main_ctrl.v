`include "define.v"
module MainCtrl(
    clk,
    rst,
    config_valid,
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
    B_col,
    ack,
    done,
    //* uni I/O
    uni_config_valid,
    uni_op,
    uni_A_src_addr,
    uni_A_channel,
    uni_A_row,
    uni_A_col,
    uni_B_src_addr,
    uni_B_channel,
    uni_B_row,
    uni_B_col,
    uni_ack,
    //* systolic I/O
    sys_config_valid,
    sys_op,
    sys_uni_src_addr,
    sys_uni_channel,
    sys_uni_row,
    sys_uni_col,
    sys_wei_src_addr,
    sys_wei_channel,
    sys_wei_row,
    sys_wei_col,
    sys_ack,
    sys_done,
    //* WB I/O
    wb_config_valid,
    wb_op,
    wb_src_addr,
    wb_channel,
    wb_row,
    wb_col,
    wb_ack,
    wb_done
);

input clk;
input rst;

input                       config_valid;
input [2:0]                 op;
input [`WORD_ADDR_BITS-1:0] WB_src_addr;
input [`DATA_MAX_BITS-1:0]  WB_channel;
input [`DATA_MAX_BITS-1:0]  WB_row;
input [`DATA_MAX_BITS-1:0]  WB_col;
input [`WORD_ADDR_BITS-1:0] A_src_addr;
input [`DATA_MAX_BITS-1:0]  A_channel;
input [`DATA_MAX_BITS-1:0]  A_row;
input [`DATA_MAX_BITS-1:0]  A_col;
input [`WORD_ADDR_BITS-1:0] B_src_addr;
input [`DATA_MAX_BITS-1:0]  B_channel;
input [`DATA_MAX_BITS-1:0]  B_row;
input [`DATA_MAX_BITS-1:0]  B_col;
output reg                     ack;
output                      done;

output reg                          uni_config_valid;
output reg [2:0]                    uni_op;
output reg [`WORD_ADDR_BITS-1:0]    uni_A_src_addr;
output reg [`DATA_MAX_BITS-1:0]     uni_A_channel;
output reg [`DATA_MAX_BITS-1:0]     uni_A_row;
output reg [`DATA_MAX_BITS-1:0]     uni_A_col;
output reg [`WORD_ADDR_BITS-1:0]    uni_B_src_addr;
output reg [`DATA_MAX_BITS-1:0]     uni_B_channel;
output reg [`DATA_MAX_BITS-1:0]     uni_B_row;
output reg [`DATA_MAX_BITS-1:0]     uni_B_col;
input                               uni_ack;

output reg                          sys_config_valid;
output reg [2:0]                    sys_op;
output reg [`WORD_ADDR_BITS-1:0]    sys_uni_src_addr;
output reg [`DATA_MAX_BITS-1:0]     sys_uni_channel;
output reg [`DATA_MAX_BITS-1:0]     sys_uni_row;
output reg [`DATA_MAX_BITS-1:0]     sys_uni_col;
output reg [`WORD_ADDR_BITS-1:0]    sys_wei_src_addr;
output reg [`DATA_MAX_BITS-1:0]     sys_wei_channel;
output reg [`DATA_MAX_BITS-1:0]     sys_wei_row;
output reg [`DATA_MAX_BITS-1:0]     sys_wei_col;
input                               sys_ack;
input                               sys_done;


output reg                          wb_config_valid;
output reg [2:0]                    wb_op;
output reg [`WORD_ADDR_BITS-1:0]    wb_src_addr;
output reg [`DATA_MAX_BITS-1:0]     wb_channel;
output reg [`DATA_MAX_BITS-1:0]     wb_row;
output reg [`DATA_MAX_BITS-1:0]     wb_col;
input                               wb_ack;
input                               wb_done;

reg [2:0]                 op_reg;
reg [`WORD_ADDR_BITS-1:0] WB_src_addr_reg;
reg [`DATA_MAX_BITS-1:0]  WB_channel_reg;
reg [`DATA_MAX_BITS-1:0]  WB_row_reg;
reg [`DATA_MAX_BITS-1:0]  WB_col_reg;
reg [`WORD_ADDR_BITS-1:0] A_src_addr_reg;
reg [`DATA_MAX_BITS-1:0]  A_channel_reg;
reg [`DATA_MAX_BITS-1:0]  A_row_reg;
reg [`DATA_MAX_BITS-1:0]  A_col_reg;
reg [`WORD_ADDR_BITS-1:0] B_src_addr_reg;
reg [`DATA_MAX_BITS-1:0]  B_channel_reg;
reg [`DATA_MAX_BITS-1:0]  B_row_reg;
reg [`DATA_MAX_BITS-1:0]  B_col_reg;

reg [4:0]                 cur_st;
reg [4:0]                 wb_cur_st;
reg [`DATA_MAX_BITS-1:0]  row_ksize;
reg [`DATA_MAX_BITS-1:0]  col_ksize;


always@(posedge clk or negedge rst) begin
    if(!rst) begin
        row_ksize <= 8'd3;
        col_ksize <= 8'd3;
        op_reg <= 0;
        A_src_addr_reg <= 0;
        A_channel_reg <= 0;
        A_row_reg <= 0;
        A_col_reg <= 0;
        B_src_addr_reg <= 0;
        B_channel_reg <= 0;
        B_row_reg <= 0;
        B_col_reg <= 0;
        uni_config_valid <= 0;
        uni_op <= 0;
        uni_A_src_addr <= 0;
        uni_A_channel <= 0;
        uni_A_row <= 0;
        uni_A_col <= 0;
        uni_B_src_addr <= 0;
        uni_B_channel <= 0;
        uni_B_row <= 0;
        uni_B_col <= 0;
        sys_config_valid <= 0;
        sys_op <= 0;
        sys_uni_src_addr <= 0;
        sys_uni_channel <= 0;
        sys_uni_row <= 0;
        sys_uni_col <= 0;
        sys_wei_src_addr <= 0;
        sys_wei_channel <= 0;
        sys_wei_row <= 0;
        sys_wei_col <= 0;
        ack <= 1'b0;
        cur_st <= 5'd0;
    end else begin
        case(cur_st)
        5'd0: begin //* initial state
            if(config_valid && op == 3'b000) begin
                A_src_addr_reg <= A_src_addr;
                A_channel_reg <= A_channel;
                A_row_reg <= A_row;
                A_col_reg <= A_col;
                B_src_addr_reg <= B_src_addr;
                B_channel_reg <= B_channel;
                B_row_reg <= B_row;
                B_col_reg <= B_col;
                uni_config_valid <= config_valid;
                uni_op <= op;
                uni_A_src_addr <= A_src_addr;
                uni_A_channel <= A_channel;
                uni_A_row <= A_row;
                uni_A_col <= A_col;
                uni_B_src_addr <= B_src_addr;
                uni_B_channel <= B_channel;
                uni_B_row <= B_row;
                uni_B_col <= B_col;
                sys_config_valid <= config_valid;
                sys_op <= op;
                sys_uni_src_addr <= 0;
                sys_uni_channel <= A_channel;
                sys_uni_row <= A_row;
                sys_uni_col <= A_col;
                sys_wei_src_addr <= 0;
                sys_wei_channel <= B_channel;
                sys_wei_row <= B_row;
                sys_wei_col <= B_col;
                ack <= 1'b1;
                cur_st <= 5'd1;
            end else if(config_valid && op == 3'b001) begin //* conv
                uni_config_valid <= config_valid;
                uni_op <= op;
                op_reg <= op;
                sys_config_valid <= config_valid;
                sys_op <= op;
                cur_st <= 5'd1;
                ack <= 1'b1;
            end else if(config_valid && op == 3'b010) begin //* mat
                uni_config_valid <= config_valid;
                uni_op <= op;
                op_reg <= op;
                sys_config_valid <= config_valid;
                sys_op <= op;
                ack <= 1'b1;
                cur_st <= 5'd1;
            end else if(sys_done) begin
                // uni_config_valid <= 1'b1;
                // uni_op <= op_reg;
                sys_config_valid <= 1'b1;
                sys_op <= op_reg;
                cur_st <= 5'd2;
            end
        end
        5'd1: begin //* wait for ack
            ack <= 1'b0;
            uni_config_valid <= 1'b0;
            sys_config_valid <= 1'b0;
            cur_st <= (uni_ack && sys_ack) ? 5'd0 : 5'd1;
        end
        5'd2: begin //* wait for sys ack
            ack <= 1'b0;
            sys_config_valid <= 1'b0;
            cur_st <= (sys_ack) ? 5'd0 : 5'd2;
        end
        endcase
    end
end

assign done = wb_done;

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        wb_cur_st <= 5'd0;
        WB_src_addr_reg <= 0;
        WB_channel_reg <= 0;
        WB_row_reg <= 0;
        WB_col_reg <= 0;
        wb_config_valid <= 0;
        wb_op <= 0;
        wb_src_addr <= 0;
        wb_row <= 0;
        wb_col <= 0;
    end else begin
        case(wb_cur_st)
        5'd0: begin //* initial state
            if(config_valid && op == 3'b000) begin
                WB_src_addr_reg <= WB_src_addr;
                WB_channel_reg <= WB_channel;
                WB_row_reg <= WB_row;
                WB_col_reg <= WB_col;
                wb_config_valid <= config_valid;
                wb_op <= op;
                wb_src_addr <= WB_src_addr;
                wb_row <= WB_row;
                wb_col <= WB_col;
                wb_cur_st <= 5'd1;
            end
        end
        5'd1: begin //* wait for ack
            wb_config_valid <= 1'b0;
            wb_cur_st <= (wb_ack) ? 5'd0 : 5'd1;
        end
        endcase
    end
end

endmodule
