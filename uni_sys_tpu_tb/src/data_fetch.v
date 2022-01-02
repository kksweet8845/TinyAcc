`include "define.v"
module DataFetch(
    clk,
    rst,
    data_ready,
    fetch,
    src_addr,
    channel,
    channel_index_rst,
    channel_index,
    row,
    row_index_rst,
    row_index,
    col,
    col_index_rst,
    col_index,
    wen,
    addr_out,
    data_NA
);

input                               clk;
input                               rst;
input                               fetch;
input                               data_ready;
input [`WORD_ADDR_BITS-1:0]         src_addr;
input [`DATA_MAX_BITS-1:0]          channel;
input                               channel_index_rst;
input [`DATA_MAX_BITS-1:0]          row;
input                               row_index_rst;
input [`DATA_MAX_BITS-1:0]          col;
input                               col_index_rst;
output                              wen;
output reg [`WORD_ADDR_BITS-1:0]    addr_out;
output reg                          data_NA;
output  [`DATA_MAX_BITS-1:0]        row_index;
output  [`DATA_MAX_BITS-1:0]        channel_index;
output  [`DATA_MAX_BITS-1:0]        col_index;




reg [`DATA_MAX_BITS-1:0]        row_index_reg;
reg [`DATA_MAX_BITS-1:0]        channel_index_reg;
reg [`DATA_MAX_BITS-1:0]        col_index_reg;



assign wen = 1'b0; //* always read
assign row_index = row_index_reg;
assign channel_index = channel_index_reg;
assign col_index = col_index_reg;


always@(posedge clk or negedge rst) begin
    if(!rst) begin
        row_index_reg <= 8'd0;
        channel_index_reg <= 8'd0;
        addr_out <= 8'd0;
        data_NA <= 1'b0;
    end else begin
        if(data_ready & fetch & !data_NA) begin
            addr_out <= (src_addr) + (channel_index_reg * row)  +  row_index_reg;
            if(!row_index_rst) begin
                row_index_reg <= (row_index_reg == row - 1) ? 8'd0 : row_index_reg + 8'd1;
            end else begin
                row_index_reg <= 8'd0;
            end
            if(!channel_index_rst) begin
                channel_index_reg <= (row_index_reg == row - 1) ? ((channel_index_reg == channel -1) ? 8'd0 : channel_index_reg + 8'd1) : channel_index_reg;
            end else begin
                channel_index_reg <= 8'd0;
            end
            data_NA <= ((channel_index_reg == channel -1) && (row_index_reg == row -1) && (~channel_index_rst) && (~row_index_rst) ) ? 1'b1 : 1'b0;
        end else if(!data_ready) begin
            row_index_reg <= 8'd0;
            channel_index_reg <= 8'd0;
            addr_out <= 8'd0;
            data_NA <= 0;
        end 
    end
end


endmodule
