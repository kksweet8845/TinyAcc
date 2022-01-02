`include "define.v"


module SYS_SETUP_CTRL(
    input clk,
    input rst,
    input start,
    input type,
    input [4:0] mat_c,
    input [4:0] mat_w,
    input [4:0] mat_h,
    input [4:0] wei_c,
    input [4:0] wei_w,
    input [4:0] wei_h,

    output [`WORD_ADDR_BITS-1:0] wei_addr,
    output wei_wen,
    input  [`WORD_SIZE-1:0] wei_data_in,

    output [`WORD_ADDR_BITS-1:0] mat_addr,
    output mat_wen,
    input  [`WORD_SIZE-1:0] mat_data_in,

    output [`WORD_SIZE-1:0] wei_data_out,
    output [`WORD_SIZE-1:0] wei_data_mask,
    output wei_valid,
    output wei_last,
    output [`WORD_SIZE-1:0] mat_data_out,
    output [`WORD_SIZE-1:0] mat_data_mask,
    output mat_valid,
    output mat_last,

    input [`WORD_SIZE-1:0] res_data_in,
    input res_valid,
    
    output [`WORD_SIZE-1:0] res_data_out,
    output [`WORD_ADDR_BITS-1:0] res_addr,
    output res_wen
);



//* type == 1 (conv), type == 0 (fc)
wire [9:0] mat_data_length;
wire [9:0] wei_data_length;



reg [3:0] cur_st;
reg [3:0] nxt_st;


always@(negedge clk or negedge rst) begin
    if(!rst) begin
        
    end else begin
        cur_st <= nxt_st;
        case(cur_st)
            4'd0: begin //* initial
                wei_addr <= 14'h3fff;
                wei_wen <= 1'b0;
                mat_addr <= 14'h3fff;
                mat_wen <= 1'b0;
                
                wei_data_out <= 128'd0;
                wei_data_mask <= 128'd0;
                wei_valid <= 1'b0;
                wei_last <= 1'b0;
                
                mat_data_out <= 128'd0;
                mat_data_mask <= 128'd0;
                mat_valid <= 1'b0;
                mat_last <= 1'b0;

                res_dat_out <= 128'd0;
                res_addr <= 14'd0;
                res_wen <= 1'b0;
            end
            4'd1: begin //* start to load data
                if(type == 1) begin
                    wei_addr <= wei_addr;
                    mat_addr <= mat_addr;
                end else begin
                    wei_addr <= (wei_addr < wei_data_length) ? 0 : wei_addr + 14'd1;
                    mat_addr <= 
                end
                
            end
        endcase
    end
end



always @(*) begin
    if(!rst) begin
       nxt_st = 4'd0; 
    end else begin
        case(cur_st)
            4'd0: nxt_st = (start) ? 4'd1: 4'd0; //* initial
            4'd1: 
        endcase
    end
end







assign mat_data_length = (type == 1) ? 9*mat_c : mat_h;
assign wei_data_length = (type == 1) ? 9 : wei_h;





























endmodule