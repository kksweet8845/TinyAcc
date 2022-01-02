`include "define.v"

module TinyML (
    input                       clk,
    input                       reset,


    input                       start,
    input    [4:0]              m,
    input    [4:0]              n,
    output reg                  done,
    
    output reg                  uni_wen,
    output reg [`WORD_SIZE-1:0] uni_addr,
    input   [`WORD_SIZE-1:0]    uni_data_in,

    output reg                  

);


//* Control Unit

//* Unified Buffer

//* Systolic Data setup

//* Weighting Buffer

//* MMU (MA)

//* Partial Sum

//* Activation Unit

//* Max Pooling







endmodule