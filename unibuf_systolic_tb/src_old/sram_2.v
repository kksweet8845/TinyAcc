`include "define.v"
module SRAM_2 (
    clk,
    rst,
    rd_valid,
    rd_addr,
    DO,
    wr_valid,
    wr_addr,
    DI,
);

input                               clk;
input                               rst;
input                               rd_valid;
input       [`WORD_ADDR_BITS-1:0]   rd_addr;
input                               wr_valid;
input       [`WORD_ADDR_BITS-1:0]   wr_addr;
input       [`WORD_SIZE-1:0]        DI;
output reg  [`WORD_SIZE-1:0]        DO;

reg [`WORD_SIZE-1:0] gbuff [0:`WORD_CNT-1];
integer i;

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        DO <= 0;
        for(i=0;i<=`WORD_CNT-1;i=i+1)
            gbuff[i] <= 128'd0;
    end else begin
        DO <= gbuff[rd_addr];
        if(wr_valid) begin
            gbuff[wr_addr] <= DI;
        end
    end
end

endmodule

