`include "define.v"
module top (
    input clk,
    input reset,

);





wire uni_wen;
wire wei_wen;

wire [`WORD_SIZE-1:0]   uni_addr;
wire [`WORD_SIZE-1:0]   uni_data_in;
wire [`WORD_SIZE-1:0]   uni_data_out;

wire [`WORD_SIZE-1:0]   wei_addr;
wire [`WORD_SIZE-1:0]   wei_data_in;
wire [`WORD_SIZE-1:0]   wei_data_out;





    SRAM unified_buffer(
        .clk        (                      clk),
        .reset      (                    reset),
        .wen        (                  uni_wen),
        .addr       (           uni_addr[15:2]),
        .DI         (              uni_data_in),
        .DO         (             uni_data_out)
    );



    SRAM weighting_buffer(
        .clk        (clk                ),
        .reset      (reset              ),
        .wen        (wei_wen            ),
        .addr       (wei_addr[15:2]     ),
        .DI         (wei_data_in        ),
        .DO         (wei_data_out       )
    );



    








endmodule