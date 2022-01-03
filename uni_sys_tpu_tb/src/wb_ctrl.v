`include "define.v"
module WBCtrl(
    clk,
    rst,
    config_valid,
    op,
    src_addr,
    channel,
    row,
    col,
    ack,
    done,
    DI_valid,
    DI,
    DO_valid,
    DO,
    DO_addr
);


input                                   clk;
input                                   rst;
input                                   config_valid;
input   [2:0]                           op;
input   [`WORD_ADDR_BITS-1:0]           src_addr;
input   [`DATA_MAX_BITS-1:0]            channel;
input   [`DATA_MAX_BITS-1:0]            row;
input   [`DATA_MAX_BITS-1:0]            col;
output  reg                             ack;
output  reg                             done;

input                                   DI_valid;
input   [`WORD_SIZE-1:0]                DI;
output reg                              DO_valid;
output reg [`WORD_SIZE-1:0]             DO;
output     [`WORD_ADDR_BITS-1:0]        DO_addr;

reg     [`DATA_MAX_BITS-1:0]    channel_reg;
reg     [`DATA_MAX_BITS-1:0]    row_reg;
reg     [`DATA_MAX_BITS-1:0]    col_reg;

reg     [`DATA_MAX_BITS-1:0]    channel_index;
reg     [`DATA_MAX_BITS-1:0]    row_index;


reg                             op_reg;
reg     [4:0]                   cur_st;


always@(posedge clk or negedge rst) begin
   if(!rst) begin
       cur_st <= 5'd0;
       channel_reg <= 0;
       row_reg <= 0;
       col_reg <= 0;
   end else begin
       case(cur_st)
        5'd0: begin
            if(config_valid && op == 3'b000) begin
                channel_reg <= channel;
                row_reg <= row;
                col_reg <= col;
                op_reg <= 1'b0;
                cur_st <= 5'd0;
                //* initialize data
                channel_index <= 8'd0;
                row_index <= 8'd0;
            end else if(config_valid && op == 3'b001) begin
                op_reg <= 1'b1;
                cur_st <= 5'd1;
                channel_index <= 8'hff;
                row_index <= 8';
            end else if(config_valid && op == 3'b010) begin
                op_reg <= 1'b0;
                cur_st <= 5'd2;
            end else begin
                cur_st <= 5'd0;
            end
            done <= 1'b0;
        end
        5'd1: begin //* store conv data
            if(DI_valid) begin
                channel_index <= (channel_index == channel_reg - 1) ? 8'd0 : channel_index + 8'd1;
                row_index <= (channel_index == channel_reg - 1) ? (row_index == row_reg -1)? 8'd0 : row_index + 8'd1 : row_index;
                DO_valid <= 1'b1;
                DO <= DI;
                cur_st <= (channel_index == channel_reg -1 && row_index == row_reg -1) ? 5'd0 : 5'd1; 
                done <= (channel_index == channel_reg -1 && row_index == row_reg -1) ? 1'b1 : 1'b0;
            end else begin
                DO_valid <= 1'b0;
                DO <= 0;
                cur_st <= 5'd1;
            end
        end
        5'd2: begin //* store mat data
            if(DI_valid) begin
                row_index <= (row_index == row_reg - 1) ? 8'd0 : row_index + 8'd1;
                channel_index <= (row_index == row_reg -1) ? (channel_index == channel_reg -1) ? 8'd0 : channel_index + 8'd1 : channel_index;
                DO_valid <= 1'b1;
                DO <= DI;
                cur_st <= (channel_index == channel_reg - 1 && row_index == row_reg - 1) ? 5'd0 : 5'd2;
                done <= (channel_index == channel_reg - 1 && row_index == row_reg - 1) ? 1'b1 : 1'b0;
            end else begin
                DO_valid <= 1'b0;
                DO <= 0;
                cur_st <= 5'd2;
            end
        end
       endcase
   end
end

assign DO_addr = channel_index * row_reg + row_index;

endmodule


