`include "define.v"
module ReLU(
    clk,
    rst,
    DI_valid,
    DI,
    DO_valid,
    DO
);


input                       clk;
input                       rst;
input                       DI_valid;
input      [`WORD_SIZE-1:0] DI;
output                      DO_valid;
output reg [`WORD_SIZE-1:0] DO;

reg        [`DATA_SIZE-1:0] relu[0:15];
integer i;

assign DO_valid = DI_valid;

always@(*) begin
    if(!rst) begin
        DO = 0;
        for(i=0;i<16;i=i+1) begin
            relu[i] = 0;
        end
    end else begin
        for(i=0;i<16;i=i+1) begin
            relu[i] = (DI[(i<<3) +: 8] >= 8'h80) ? 0 : DI[(i<<3) +: 8];
        end
        DO = {relu[15], relu[14], relu[13], relu[12], relu[11], relu[10], relu[9], relu[8], relu[7], relu[6], relu[5], relu[4], relu[3], relu[2], relu[1], relu[0]};
    end   
end

endmodule