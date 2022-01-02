`include "define.v"
module ZeroPadding(
    rst,
    padding_size,
    col_size,
    DI,
    DO
);

input                            rst;
input       [3:0]                padding_size;
input       [3:0]                col_size;
input       [`WORD_SIZE-1:0]     DI;
output reg  [`WORD_SIZE-1:0]     DO;

always@(*) begin
    if(!rst) begin
        DO = 128'd0;
    end else begin
        case(padding_size)
            4'b0000: DO =  DI;
            4'b0001: DO = (DI >> 8);
            4'b0010: DO = (DI >> 16);
            4'b0011: DO = (DI >> 24);
            4'b0100: DO = (DI >> 32);
            4'b0101: DO = (DI >> 40);
            4'b0110: DO = (DI >> 48);
            4'b0111: DO = (DI >> 56);
            4'b1000: DO =  DI;
            4'b1001: DO = (DI << 56);
            4'b1010: DO = (DI << 48);
            4'b1011: DO = (DI << 40);
            4'b1100: DO = (DI << 43);
            4'b1101: DO = (DI << 24);
            4'b1110: DO = (DI << 16);
            4'b1111: DO = (DI << 8);
        endcase

        case(col_size)
            4'd0    : DO = 128'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff & DO;
            4'd1    : DO = 128'hff00_0000_0000_0000_0000_0000_0000_0000 & DO;
            4'd2    : DO = 128'hffff_0000_0000_0000_0000_0000_0000_0000 & DO;
            4'd3    : DO = 128'hffff_ff00_0000_0000_0000_0000_0000_0000 & DO;
            4'd4    : DO = 128'hffff_ffff_0000_0000_0000_0000_0000_0000 & DO;
            4'd5    : DO = 128'hffff_ffff_ff00_0000_0000_0000_0000_0000 & DO;
            4'd6    : DO = 128'hffff_ffff_ffff_0000_0000_0000_0000_0000 & DO;
            4'd7    : DO = 128'hffff_ffff_ffff_ff00_0000_0000_0000_0000 & DO;
            4'd8    : DO = 128'hffff_ffff_ffff_ffff_0000_0000_0000_0000 & DO;
            4'd9    : DO = 128'hffff_ffff_ffff_ffff_ff00_0000_0000_0000 & DO;
            4'd10   : DO = 128'hffff_ffff_ffff_ffff_ffff_0000_0000_0000 & DO;
            4'd11   : DO = 128'hffff_ffff_ffff_ffff_ffff_ff00_0000_0000 & DO;
            4'd12   : DO = 128'hffff_ffff_ffff_ffff_ffff_ffff_0000_0000 & DO;
            4'd13   : DO = 128'hffff_ffff_ffff_ffff_ffff_ffff_ff00_0000 & DO;
            4'd14   : DO = 128'hffff_ffff_ffff_ffff_ffff_ffff_ffff_0000 & DO;
            4'd15   : DO = 128'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ff00 & DO;
        endcase
    end
end


endmodule