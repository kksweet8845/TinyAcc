`include "define.v"
module Systolic(
    clk,
    rst,
    op,
    config_valid,
    uni_src_addr,
    uni_channel,
    uni_row,
    uni_col,
    wei_src_addr,
    wei_channel,
    wei_row,
    wei_col,
    ack,
    done,
    uni_ready,
    uni_wen,
    uni_addr,
    uni_data,
    wei_ready,
    wei_wen,
    wei_addr,
    wei_data,
    DO_valid,
    DO_uni,
    DO_wei
);



input                               clk;
input                               rst;

//* The opcode
input [2:0]                         op;

//* Valid signal of config  
input                               config_valid;

//* the src data address
input       [`WORD_ADDR_BITS-1:0]   uni_src_addr;
input       [`WORD_ADDR_BITS-1:0]   wei_src_addr;

//* The unified buffer channel size
input       [`DATA_MAX_BITS-1:0]    uni_channel;
input       [`DATA_MAX_BITS-1:0]    wei_channel;

//* The unified buffer row size
input       [`DATA_MAX_BITS-1:0]    uni_row;
input       [`DATA_MAX_BITS-1:0]    wei_row;

//* The unified buffer col size
input       [`DATA_MAX_BITS-1:0]    uni_col;
input       [`DATA_MAX_BITS-1:0]    wei_col;

//* Ack signal
output      reg                     ack;
output      reg                     done;

//* Unified Buffer signals
input                               uni_ready;
output                              uni_wen;
output      [`WORD_ADDR_BITS-1:0]   uni_addr;
input       [`WORD_SIZE-1:0]        uni_data;

//* Weighting Buffer signals
input                               wei_ready;
output                              wei_wen;
output      [`WORD_ADDR_BITS-1:0]   wei_addr;
input       [`WORD_SIZE-1:0]        wei_data;

//* Data Out signals
output                              DO_valid;
output      [`WORD_SIZE-1:0]        DO_uni;
output      [`WORD_SIZE-1:0]        DO_wei;



reg [`WORD_SIZE-1:0]                uni_data_buf;
reg                                 uni_data_buf_valid;

reg [4:0]                           cur_st;
wire                                conf_op;
wire                                conv_op;
wire                                mat_op;
reg                                 op_reg;


reg  [`WORD_ADDR_BITS-1:0]          uni_src_addr_reg;
reg  [`WORD_ADDR_BITS-1:0]          wei_src_addr_reg;
reg  [`DATA_MAX_BITS-1:0]           uni_channel_reg;
reg  [`DATA_MAX_BITS-1:0]           wei_channel_reg;

reg  [`DATA_MAX_BITS-1:0]           uni_row_reg;
reg  [`DATA_MAX_BITS-1:0]           wei_row_reg;

reg  [`DATA_MAX_BITS-1:0]           uni_col_reg;
reg  [`DATA_MAX_BITS-1:0]           wei_col_reg;

//* Uni
wire [`DATA_MAX_BITS-1:0]            uni_channel_index;
wire [`DATA_MAX_BITS-1:0]            uni_row_index;
reg [`DATA_MAX_BITS-1:0]             uni_col_index;

//* Wei
wire [`DATA_MAX_BITS-1:0]            wei_channel_index;
wire [`DATA_MAX_BITS-1:0]            wei_row_index;
reg [`DATA_MAX_BITS-1:0]             wei_col_index;

reg  [3:0]                          padding_size_reg;

wire                                uni_data_NA;
wire                                wei_data_NA;

wire [`WORD_SIZE-1:0]               uni_zero_pad_DO;
wire [`WORD_SIZE-1:0]               uni_zero_pad_DI;
reg  [3:0]                          stall_cnt;

reg                                 uni_data_fetch;
reg                                 wei_data_fetch;
reg                                 uni_out_valid;
reg                                 wei_out_valid;

wire                                wei_channel_index_rst;
reg                                 wei_row_index_rst;
wire                                uni_channel_index_rst;
wire                                uni_row_index_rst;

reg [`DATA_MAX_BITS-1:0]            kernel_size;
reg [`WORD_SIZE-1:0]                uni_zero_pad_DO_reg;
reg [9:0]                           DO_cnt;
wire [9:0]                          mat_total;
wire [9:0]                          DO_total;

integer i;


always@(posedge clk or negedge rst) begin
    if(!rst) begin
        cur_st <= 5'd0;
        stall_cnt <= 0;
        uni_src_addr_reg <= 0;
        wei_src_addr_reg <= 0;
        uni_channel_reg <= 0;
        wei_channel_reg <= 0;
        uni_row_reg <= 0;
        wei_row_reg <= 0;
        uni_col_reg <= 0;
        wei_col_reg <= 0;
        uni_col_index <= 0;
        wei_col_index <= 0;
        op_reg <= 0;
        uni_data_fetch <= 1'b0;
        wei_data_fetch <= 1'b0;
        uni_out_valid <= 1'b0;
        wei_out_valid <= 1'b0;
        wei_row_index_rst <= 1'b0;
        done <= 1'b0;
        ack <= 1'b0;
        uni_data_buf_valid <= 1'b0;
        uni_data_buf <= 0;
        kernel_size <= 8'd3;
        DO_cnt <= 0;
    end else begin
        case(cur_st)
            5'd0: begin //* Waiting for configuration and start
                if(config_valid & conf_op) begin
                    uni_src_addr_reg    <= uni_src_addr;
                    wei_src_addr_reg    <= wei_src_addr;
                    uni_channel_reg     <= uni_channel;
                    wei_channel_reg     <= wei_channel;
                    uni_row_reg         <= uni_row;
                    wei_row_reg         <= wei_row;
                    uni_col_reg         <= uni_col;
                    wei_col_reg         <= wei_col;
                    ack                 <= 1'b1;
                    cur_st <= 5'd0;
                end else if(config_valid & conv_op) begin
                    op_reg  <= 1'b1;
                    uni_row_reg <= 8'd3;
                    cur_st  <= 5'd1;
                    ack     <= 1'b1;
                end else if(config_valid & mat_op) begin
                    op_reg  <= 1'b0;
                    cur_st  <= 5'd1;
                    ack     <= 1'b1;
                end else begin
                    ack     <= 1'b0;
                    cur_st  <= 5'd0;
                    op_reg  <= 1'b0;
                    done <= 1'b0;
                    uni_col_index <= 0;
                    wei_col_index <= 0;
                    op_reg <= 0;
                    uni_data_fetch <= 1'b0;
                    wei_data_fetch <= 1'b0;
                    uni_out_valid <= 1'b0;
                    wei_out_valid <= 1'b0;
                    wei_row_index_rst <= 1'b0;
                    uni_data_buf_valid <= 1'b0;
                    uni_data_buf <= 0;
                    kernel_size <= 8'd3;
                    DO_cnt <= 0;
                end
            end
            5'd1: begin //* Unified buf and weighting buf ready, op_reg == 1'b1 is conv
                ack <= 1'b0;
                cur_st <= (uni_ready & wei_ready) ? ((op_reg == 1'b1) ? 5'd2 : 5'd3) : 5'd1;
            end
            5'd2: begin //* conv fetch data I
                uni_data_fetch <= (stall_cnt < 4'd1) ? 1'b1 : 1'b0;
                wei_data_fetch <= (stall_cnt == 4'd2) ? 1'b1 : 1'b0;
                stall_cnt <= (stall_cnt == 4'd2) ? 4'd0 : stall_cnt + 4'd1;
                cur_st     <=  (stall_cnt == 4'd2) ? 5'd5 : 5'd2;
            end
            5'd3: begin //* matrix fetch data
                uni_data_fetch <= 1'b1;
                wei_data_fetch <= 1'b1;
                stall_cnt <= (stall_cnt == 4'd1) ? 4'd0 : stall_cnt + 4'd1;
                cur_st <= (stall_cnt == 4'd1) ? 5'd4 : 5'd3; //* Wait until data comes
                DO_cnt <= 10'h3ff;
            end
            5'd4: begin //* No data available, reset of setting
                uni_out_valid <= (DO_cnt == DO_total - 1) ? 1'b0 : 1'b1;
                wei_out_valid <= (DO_cnt == DO_total - 1) ? 1'b0 : 1'b1;
                DO_cnt <= (DO_cnt == DO_total - 1) ? 0 : DO_cnt + 10'd1;
                cur_st <= (DO_cnt == DO_total - 1) ? 5'd0 : 5'd4;
                done <= (DO_cnt == DO_total - 1) ? 1'b1 : 1'b0;
            end
            5'd5: begin //* Store data
                uni_data_fetch <= 1'b1;
                uni_data_buf <= uni_data;
                uni_data_buf_valid <= 1'b1;
                cur_st <= 5'd6;
                wei_col_index <= 8'd0;
                padding_size_reg <= 4'h0;
                DO_cnt <= 10'h3ff;
            end
            5'd6: begin //* Conv obtain data and start feeding process
                uni_out_valid <= (DO_cnt == DO_total -1) ? 1'b0 : 1'b1;
                wei_out_valid <= (DO_cnt == DO_total -1) ? 1'b0 : 1'b1;
                uni_data_fetch <= (!uni_data_NA) && (wei_col_index == kernel_size-1) ? 1'b1 : 1'b0; 
                uni_data_buf <= (wei_col_index == kernel_size -1) ? uni_data : uni_data_buf;
                wei_data_fetch <= (uni_data_NA & wei_data_NA) ? 1'b0 : 1'b1;
                wei_row_index_rst <=  ((wei_row_index == wei_row_reg-2) || (DO_cnt == DO_total - 1)) ? 1'b1 : 1'b0;
                DO_cnt <= (DO_cnt == DO_total -1) ? 0 : DO_cnt + 10'd1;
                wei_col_index <= (wei_col_index == kernel_size -1) ? 8'd0 : wei_col_index + 8'd1;
                cur_st <= (DO_cnt == DO_total -1) ? 5'd0 : 5'd6;
                done <= (DO_cnt == DO_total -1) ? 1'b1 : 1'b0;
            end
        endcase
        uni_zero_pad_DO_reg <= uni_zero_pad_DO; //* Store the cb val
    end
end

always@(*) begin
    if(!rst) begin
        padding_size_reg = 4'd0;
    end else begin
        case(wei_col_index) //* wei_col_index is not correct, should rename
            8'd0: padding_size_reg = 4'h0;
            8'd1: padding_size_reg = 4'h1;
            8'd2: padding_size_reg = 4'hf;
            8'd3: padding_size_reg = 4'h2;
            4'd4: padding_size_reg = 4'he;
        endcase
    end
end




assign conf_op = op == 3'b000 ? 1'b1 : 1'b0;
assign conv_op = op == 3'b001 ? 1'b1 : 1'b0;
assign  mat_op = op == 3'b010 ? 1'b1 : 1'b0;



assign uni_zero_pad_DI = (uni_data_buf_valid) ? uni_data_buf : 0;
assign mat_total = uni_channel_reg * uni_row_reg;
assign DO_total = (op_reg == 1'b1) ? mat_total * 3 : uni_row_reg;
assign DO_valid = (uni_out_valid & wei_out_valid) ? 1'b1 : 1'b0;
assign DO_uni   =  (op_reg == 1'b1) ? uni_zero_pad_DO_reg : uni_data;
assign DO_wei   =  wei_data;

assign uni_channel_index_rst = 0;
assign uni_row_index_rst    = 0;
assign wei_channel_index_rst = 0; //* If channel is 1, always unset. and if channel is greater than 1, also don't need to change

    DataFetch uni_fetcher(
        .clk                (clk                    ),
        .rst                (rst                    ),
        .data_ready         (uni_ready              ),
        .fetch              (uni_data_fetch         ),
        .src_addr           (uni_src_addr_reg       ),
        .channel            (uni_channel_reg        ),
        .channel_index_rst  (uni_channel_index_rst  ),
        .channel_index      (uni_channel_index      ),
        .row                (uni_row_reg            ),
        .row_index_rst      (uni_row_index_rst      ),
        .row_index          (uni_row_index          ),
        .wen                (uni_wen                ),
        .addr_out           (uni_addr               ),
        .data_NA            (uni_data_NA            )
    );

    DataFetch wei_fetcher(
        .clk                (clk                    ),
        .rst                (rst                    ),
        .data_ready         (wei_ready              ),
        .fetch              (wei_data_fetch         ),
        .src_addr           (wei_src_addr_reg       ),
        .channel            (wei_channel_reg        ),
        .channel_index_rst  (wei_channel_index_rst  ),
        .channel_index      (wei_channel_index      ),
        .row                (wei_row_reg            ),
        .row_index_rst      (wei_row_index_rst      ),
        .row_index          (wei_row_index          ),
        .wen                (wei_wen                ),
        .addr_out           (wei_addr               ),
        .data_NA            (wei_data_NA            )
    );

    ZeroPadding zp_i(
        .rst                (rst                    ),
        .padding_size       (padding_size_reg       ),
        .col_size           (uni_col_reg[3:0]       ),
        .DI                 (uni_zero_pad_DI        ),
        .DO                 (uni_zero_pad_DO        )
    );


endmodule








