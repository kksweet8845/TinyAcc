`include "define.v"
module ConvCtrl(
    clk,
    rst,
    op_valid,
    op,
    ack,
    data_NA,
    channel,
    row,
    col,
    row_ksize,
    col_ksize,
    fetch_wen,
    fetch_addr,
    fetch_DI,
    write_wen,
    write_addr,
    write_DO,
    data_ready
);

input                               clk;
input                               rst;
input                               op_valid;
input   [2:0]                       op;
output  reg                         ack;
output  reg                         data_NA;

input   [`DATA_MAX_BITS-1:0]        channel;
input   [`DATA_MAX_BITS-1:0]        row;
input   [`DATA_MAX_BITS-1:0]        col;

input   [`DATA_MAX_BITS-1:0]        row_ksize;
input   [`DATA_MAX_BITS-1:0]        col_ksize;

output  reg                         fetch_wen;
output  [`WORD_ADDR_BITS-1:0]       fetch_addr;
input   [`WORD_SIZE-1:0]            fetch_DI;

output  reg                         write_wen;
output  [`WORD_ADDR_BITS-1:0]       write_addr;
output  reg [`WORD_SIZE-1:0]        write_DO;
output  reg                         data_ready;


reg     [4:0]                   cur_st;

reg     [`DATA_MAX_BITS-1:0]    channel_reg;
reg     [`DATA_MAX_BITS-1:0]    row_reg;
reg     [`DATA_MAX_BITS-1:0]    col_reg;
reg     [`DATA_MAX_BITS-1:0]    row_ksize_reg;
reg     [`DATA_MAX_BITS-1:0]    col_ksize_reg;

reg     [`DATA_MAX_BITS-1:0]    fetch_channel_index;
reg     [`DATA_MAX_BITS-1:0]    fetch_row_index;

reg     [`DATA_MAX_BITS-1:0]    write_channel_index;
reg     [`DATA_MAX_BITS-1:0]    write_row_index;

reg     [`DATA_MAX_BITS-1:0]    row_base;
reg     [`DATA_MAX_BITS-1:0]    row_base_index;
reg     [`DATA_MAX_BITS-1:0]    row_base_cnt;
reg     [`DATA_MAX_BITS-1:0]    channel_index;
reg     [`DATA_MAX_BITS-1:0]    cycle_cnt;
reg                             last_fetch;

wire    [`DATA_MAX_BITS-1:0]    row_psize;
wire    [`DATA_MAX_BITS-1:0]    col_psize;

wire    [`DATA_MAX_BITS-1:0]    _prepend_min;
wire    [`DATA_MAX_BITS-1:0]    _prepend_max;
wire    [`DATA_MAX_BITS-1:0]    _append_min;
wire    [`DATA_MAX_BITS-1:0]    _append_max;




always@(posedge clk or negedge rst) begin
    if(!rst) begin
        ack <= 1'b0;
        data_NA <= 1'b0;
        fetch_wen <= 1'b0;
        write_wen <= 1'b0;
        write_DO <= 0;
        data_ready <= 0;
        cur_st <= 5'd0;
        channel_reg <= 0;
        row_reg <= 0;
        col_reg <= 0;
        row_ksize_reg <= 0;
        col_ksize_reg <= 0;
        fetch_channel_index <= 0;
        fetch_row_index <= 0;
        write_channel_index <= 0;
        write_row_index <= 0;
        row_base <= 0;
        row_base_cnt <= 0;
        row_base_index <= 0;
        channel_index <= 0;
        cycle_cnt <= 0;
        last_fetch <= 0;
    end else begin
        case(cur_st)
            5'd0: begin //* Initial state
                if(op_valid && op == 3'b001) begin //* config
                    channel_reg     <= channel;
                    row_reg         <= row;
                    col_reg         <= col;
                    row_ksize_reg   <= row_ksize;
                    col_ksize_reg   <= col_ksize;
                    ack             <= 1'b1;
                    //* Initialize all data
                    data_NA <= 1'b0;
                    fetch_wen <= 1'b0;
                    write_wen <= 1'b0;
                    write_DO <= 0;
                    data_ready <= 0;
                    fetch_channel_index <= 0;
                    fetch_row_index <= 0;
                    write_channel_index <= 0;
                    write_row_index <= 0;
                    row_base <= 0;
                    row_base_cnt <= 0;
                    row_base_index <= 0;
                    channel_index <= 8'hff;
                    cycle_cnt <= 0;
                    last_fetch <= 0;
                    cur_st <= 5'd0;
                end else if(op_valid && op == 3'b010) begin //* start or resume fetch data
                    cur_st <= (last_fetch) ? 5'd0 : 5'd1;
                    data_NA <= (last_fetch) ? 1'b1 : 1'b0;
                    data_ready <= 1'b0;
                    channel_index <= 8'hff;
                    ack <= 1'b1;
                end else begin
                    cur_st <= 5'd0;
                    ack <= 1'b0;
                end
            end
            5'd1: begin //* update row_base & channel index
                ack <= 1'b0;
                channel_index <= (channel_index == channel_reg -1) ? 8'd0 : channel_index + 8'd1;
                row_base <= (channel_index == channel_reg - 1) ? (row_base == row_reg - 1) ? 8'd0 : row_base + 8'd1 : row_base;
                row_base_index <= 8'hff;
                row_base_cnt <= 8'hff;
                cur_st <= (channel_index == channel_reg - 1) ? 5'd0 : 5'd2;
                data_ready <= (channel_index == channel_reg - 1) ? 1'b1 : 1'b0;
                last_fetch <= (channel_index == channel_reg - 1 && row_base == row_reg - 1) ? 1'b1 : 1'b0;
                write_wen <= 1'b0;
            end
            5'd2: begin //* update row_base_index and row_base_cnt
                write_wen <= 1'b0;
                row_base_index <= (row_base_index == 8'hff) ? row_base : (row_base_index == row_base+row_ksize-1) ? row_base : row_base_index + 8'd1;
                // row_base_index <= (row_base_index == row_base+row_ksize_reg-1) ? row_base : row_base_index + 8'd1;
                row_base_cnt <= (row_base_cnt == row_ksize_reg-1) ? 8'd0 : row_base_cnt + 8'd1;
                cycle_cnt <= 8'd0;
                cur_st <= (row_base_cnt == row_ksize_reg -1) ? 5'd1 : 5'd3;
            end
            5'd3: begin //* check padding or not
                if((row_base_index >= _prepend_min && row_base_index <= _prepend_max) || (row_base_index >= _append_min && row_base_index <= _append_max )) begin
                    //* write zero data
                    write_channel_index <= channel_index;
                    write_row_index <= row_base_cnt;
                    write_DO <= 0;
                    write_wen <= 1;
                    cur_st <= 5'd2;
                end else begin
                    //* fetch data
                    cycle_cnt <= cycle_cnt + 8'd1;
                    fetch_channel_index <= channel_index;
                    fetch_row_index <= row_base_index - row_psize;
                    fetch_wen <= 1'b0;
                    write_channel_index <= channel_index;
                    write_row_index <= row_base_cnt;
                    write_DO <= (cycle_cnt == 8'd2) ? fetch_DI : 0;
                    write_wen <= (cycle_cnt == 8'd2) ? 1'b1 : 1'b0;
                    cur_st <= (cycle_cnt == 8'd2) ? 5'd2 : 5'd3;
                end
            end
        endcase
    end
end

assign fetch_addr = (fetch_channel_index * row_reg) + fetch_row_index; 
assign write_addr = (write_channel_index * row_ksize_reg) + (write_row_index);

assign _prepend_min = 8'd0;
assign _prepend_max = row_psize - 1;
assign _append_min = row_reg + row_psize;
assign _append_max = row_reg + row_ksize_reg - 2;

assign row_psize = (row_ksize_reg - 1) >> 1;
assign col_psize = (col_ksize_reg - 1) >> 1;


endmodule
