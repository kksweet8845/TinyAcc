`include "define.v"
module MaxCtrl(
    clk,
    rst,
    op_valid,
    op,
    ack,
    data_NA,
    channel,
    row,
    col,
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

output  reg                         fetch_wen;
output  [`WORD_ADDR_BITS-1:0]       fetch_addr;
input   [`WORD_SIZE-1:0]            fetch_DI;

output  reg                         write_wen;
output      [`WORD_ADDR_BITS-1:0]   write_addr;
output  reg [`WORD_SIZE-1:0]        write_DO;
output  reg                         data_ready;

reg     [`DATA_MAX_BITS-1:0]        channel_reg;
reg     [`DATA_MAX_BITS-1:0]        row_reg;
reg     [`DATA_MAX_BITS-1:0]        col_reg;

reg     [`DATA_MAX_BITS-1:0]        fetch_channel_index;
reg     [`DATA_MAX_BITS-1:0]        fetch_row_index;

reg     [`DATA_MAX_BITS-1:0]        write_channel_index;
reg     [`DATA_MAX_BITS-1:0]        write_row_index;

reg     [`DATA_MAX_BITS-1:0]        cycle_cnt;
reg     [4:0]                       cur_st;
reg                                 last_fetch;


always@(posedge clk or negedge rst) begin
    if(!rst) begin
        ack <= 0;
        data_NA <= 0;
        fetch_wen <= 0;
        write_wen <= 0;
        write_DO <= 0;
        data_ready <= 0;
        channel_reg <= 0;
        row_reg <= 0;
        col_reg <= 0;
        fetch_channel_index <= 0;
        fetch_row_index <= 0;
        write_channel_index <= 0;
        write_row_index <= 0;
        cycle_cnt <= 0;
        cur_st <= 5'd0;
        last_fetch <= 1'b0;
    end else begin
        case(cur_st)
            5'd0: begin //* Initial state
                if(op_valid && op == 3'b001) begin //* config
                    channel_reg     <= channel;
                    row_reg         <= row;
                    col_reg         <= col;
                    ack             <= 1'b1;
                    //* Initialize all data
                    data_NA <= 0;
                    fetch_wen <= 0;
                    write_wen <= 0;
                    write_DO <= 0;
                    data_ready <= 0;
                    fetch_channel_index <= 0;
                    fetch_row_index <= 0;
                    write_channel_index <= 0;
                    write_row_index <= 8'hff;
                    cycle_cnt <= 0;
                    last_fetch <= 1'b0;
                    cur_st <= 5'd0;
                    data_ready <= 1'b0;
                end else if(op_valid && op == 3'b011) begin //* start fetch data
                    cur_st <= (last_fetch) ? 5'd0 : 5'd1;
                    data_NA <= (last_fetch) ? 1'b1 : 1'b0; 
                    cycle_cnt <= 8'hff;
                    fetch_row_index <= 8'hff;
                    write_row_index <= 8'hff;
                    ack <= 1'b1;
                    data_ready <= 1'b0;
                    write_wen <= 1'b0;
                end else begin
                    cur_st <= 5'd0;
                    ack <= 1'b0;
                    write_wen <= 1'b0;
                end
            end
            5'd1: begin //* fetch data
                ack <= 1'b0;
                cycle_cnt <= (cycle_cnt == 8'hff) ? 8'd0 : cycle_cnt + 8'd1;
                fetch_row_index <= (fetch_row_index == row_reg - 1) ? 8'd0 : fetch_row_index + 8'd1;
                fetch_channel_index <= (fetch_row_index == row_reg - 1) ? (fetch_channel_index == channel_reg -1) ? 8'd0 : fetch_channel_index + 8'd1 : fetch_channel_index;
                if(cycle_cnt >= 8'd1 && cycle_cnt <= row_reg) begin
                    write_channel_index <= (write_row_index == row_reg - 1) ? (write_channel_index == channel_reg - 1) ? 8'd0 : write_channel_index + 8'd1 : write_channel_index;
                    write_row_index <= (write_row_index == row_reg - 1)? 8'd0 : write_row_index + 8'd1;
                    write_wen <= 1'b1;
                    write_DO <= fetch_DI;
                end else begin
                    write_wen <= 1'b0;
                    write_row_index <= (write_row_index == row_reg - 1) ? 8'd0 : write_row_index;
                    write_DO <= 0;
                end
                cur_st <= (write_row_index == row_reg - 1) ? 5'd0 : 5'd1;
                data_ready <= (write_row_index == row_reg - 1) ? 1'b1 : 1'b0;
                last_fetch <= (fetch_channel_index == channel_reg - 1 && fetch_row_index == row_reg - 1) ? 1'b1 : 1'b0; 
            end
        endcase
    end
end

assign fetch_addr = (fetch_channel_index * row_reg) + fetch_row_index; 
assign write_addr = (write_channel_index * row_reg) + (write_row_index);

endmodule