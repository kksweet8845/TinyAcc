//----------------------------------------------------------------------------//
// Common Definations                                                         //
//----------------------------------------------------------------------------//
`define DATA_SIZE 8
// `define WORD_SIZE 32
`define GBUFF_ADDR_SIZE 256
//`define GBUFF_INDX_SIZE (GBUFF_ADDR_SIZE/WORD_SIZE)
`define GBUFF_INDX_SIZE 8
`define GBUFF_SIZE (WORD_SIZE*GBUFF_ADDR_SIZE)


`define BYTES_SIZE  8
`define BYTES_CNT   16
`define WORD_SIZE   128
`define WORD_ADDR_BITS 14
`define WORD_CNT (1 << WORD_ADDR_BITS)

//----------------------------------------------------------------------------//
// Simulations Definations                                                    //
//----------------------------------------------------------------------------//
`define CYCLE 10
`define MAX   500000

//----------------------------------------------------------------------------//
// User Definations                                                           //
//----------------------------------------------------------------------------//