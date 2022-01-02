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
always @(posedge clk)
begin
    if($signed(x) >= 0)
    begin
        if(|x[2*dataWidth-1-:weightIntWidth+1]) //over flow to sign bit of integer part
            out <= {1'b0,{(dataWidth-1){1'b1}}}; //positive saturate
        else
            out <= x[2*dataWidth-1-weightIntWidth-:dataWidth];
    end
    else 
        out <= 0;      
end





endmodule