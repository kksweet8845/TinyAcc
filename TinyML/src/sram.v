
`include "define.v"
module SRAM (
    clk,
    reset,
    wen,
    addr,
    DI,
    DO
);

input                           clk;
input                           rst;
input  [`WORD_ADDR_BITS-1:0]    addr;
input                           wen;
input  [`WORD_SIZE-1:0]         DI;
output [`WORD_SIZE-1:0]         DO;

reg [`WORD_SIZE-1:0] gbuff [0:`WORD_CNT];
integer i;

always@(posedge clk or reset) begin
    if(reset) begin
        for(i=0;i<=`WORD_CNT;i=i+1)
            gbuff[i] <= 128'd0;
    end else begin
        if(wen) begin
            gbuff[addr] <= DI;
        end else begin
            DO <= gbuff[addr];
        end
    end
end

endmodule

