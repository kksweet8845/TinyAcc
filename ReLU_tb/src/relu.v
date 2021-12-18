`define "define.v"
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
output reg                  DO_valid;
output reg [`WORD_SIZE-1:0] DO;


//* Your Design Here
always@(posedge clk or negedge rst) begin
    if(!rst) begin

    end else begin

    end 
end





endmodule