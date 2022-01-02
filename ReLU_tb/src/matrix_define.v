
`ifndef MATRIX_DEFINE_V
`define MATRIX_DEFINE_V

`include "matrix_define.v"
`endif



`ifndef DEFINE_V
`define DEFINE_V

`define DATA_SIZE 8
`define WORD_SIZE 32
`define GBUFF_ADDR_SIZE 256
//`define GBUFF_INDX_SIZE (GBUFF_ADDR_SIZE/WORD_SIZE)
`define GBUFF_INDX_SIZE 8
`define GBUFF_SIZE (WORD_SIZE*GBUFF_ADDR_SIZE)


`define CYCLE 10
`define MAX   500000



`endif