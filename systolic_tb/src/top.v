`include "define.v"

module TOP(
    clk,
    rst,
    instr_valid,
    instr,
    A_ready,
    B_ready,
    ack,
    done
);


input clk;
input rst;
input instr_valid;
input [70:0] instr;
input A_ready;
input B_ready;
output ack;
output done;


//* Systolic wires
wire [2:0]   op;
wire config_valid;
wire   [`WORD_ADDR_BITS-1:0]   uni_src_addr;
wire   [`WORD_ADDR_BITS-1:0]   wei_src_addr;
wire   [`DATA_MAX_BITS-1:0]    uni_channel;
wire   [`DATA_MAX_BITS-1:0]    wei_channel;
wire   [`DATA_MAX_BITS-1:0]    uni_row;
wire   [`DATA_MAX_BITS-1:0]    wei_row;
wire   [`DATA_MAX_BITS-1:0]    uni_col;
wire   [`DATA_MAX_BITS-1:0]    wei_col;

wire                            uni_ready;
wire                            uni_wen;
wire   [`WORD_ADDR_BITS-1:0]    uni_addr;
wire   [`WORD_SIZE-1:0]         uni_data;

wire                            wei_ready;
wire                            wei_wen;
wire   [`WORD_ADDR_BITS-1:0]    wei_addr;
wire   [`WORD_SIZE-1:0]         wei_data;

wire                            DO_valid;
wire   [`WORD_SIZE-1:0]         DO_uni;
wire   [`WORD_SIZE-1:0]         DO_wei;                        



//* BUFFER A wires
wire                            A_wen;
wire   [`WORD_ADDR_BITS-1:0]    A_addr;
wire   [`WORD_SIZE-1:0]         A_DI;
wire   [`WORD_SIZE-1:0]         A_DO;

//* BUFFER B wires
wire                            B_wen;
wire   [`WORD_ADDR_BITS-1:0]    B_addr;
wire   [`WORD_SIZE-1:0]         B_DI;
wire   [`WORD_SIZE-1:0]         B_DO;

//* BUFFER UNI OUT wires
wire                            O_uni_wen;
wire   [`WORD_ADDR_BITS-1:0]    O_uni_addr;
wire   [`WORD_SIZE-1:0]         O_uni_DI;
wire   [`WORD_SIZE-1:0]         O_uni_DO;


//* BUFFER WEI OUT wires
wire                            O_wei_wen;
wire   [`WORD_ADDR_BITS-1:0]    O_wei_addr;
wire   [`WORD_SIZE-1:0]         O_wei_DI;
wire   [`WORD_SIZE-1:0]         O_wei_DO;

reg    [9:0]                    O_index;


always@(posedge clk or negedge rst) begin
    if(!rst) begin
        O_index <= 10'd0;
    end else begin
        O_index <= (DO_valid) ?  O_index + 10'd1 : O_index;
    end
end






    Systolic systolic_i(
        .clk            (clk            ),
        .rst            (rst            ),
        .op             (op             ),
        .config_valid   (config_valid   ),
        .uni_src_addr   (uni_src_addr   ),
        .uni_channel    (uni_channel    ),
        .uni_row        (uni_row        ),
        .uni_col        (uni_col        ),
        .wei_src_addr   (wei_src_addr   ),
        .wei_channel    (wei_channel    ),
        .wei_row        (wei_row        ),
        .wei_col        (wei_col        ),
        .ack            (ack            ),
        .done           (done           ),
        .uni_ready      (uni_ready      ),
        .uni_wen        (uni_wen        ),
        .uni_addr       (uni_addr       ),
        .uni_data       (uni_data       ),
        .wei_ready      (wei_ready      ),
        .wei_wen        (wei_wen        ),
        .wei_addr       (wei_addr       ),
        .wei_data       (wei_data       ),
        .DO_valid       (DO_valid       ),
        .DO_uni         (DO_uni         ),
        .DO_wei         (DO_wei         )
    );


    //* UNI data
    SRAM GBUFF_A(
        .clk            (clk            ),
        .rst            (rst            ),
        .wen            (A_wen          ),
        .addr           (A_addr         ),
        .DI             (A_DI           ),
        .DO             (A_DO           )
    );


    //* WEI data
    SRAM GBUFF_B(
        .clk            (clk            ),
        .rst            (rst            ),
        .wen            (B_wen          ),
        .addr           (B_addr         ),
        .DI             (B_DI           ),
        .DO             (B_DO           )
    );

    //* O_uni data
    SRAM GBUFF_O_uni(
        .clk            (clk            ),
        .rst            (rst            ),
        .wen            (O_uni_wen      ),
        .addr           (O_uni_addr     ),
        .DI             (O_uni_DI       ),
        .DO             (O_uni_DO       )
    );

    //* O_wei data
    SRAM GBUFF_O_wei(
        .clk            (clk            ),
        .rst            (rst            ),
        .wen            (O_wei_wen      ),
        .addr           (O_wei_addr     ),
        .DI             (O_wei_DI       ),
        .DO             (O_wei_DO       )
    );




assign config_valid = instr_valid;
assign op = instr[70:68];
assign uni_src_addr = instr[67:58];
assign uni_channel  = instr[57:50];
assign uni_row      = instr[49:42];
assign uni_col      = instr[41:34];

assign wei_src_addr = instr[33:24];
assign wei_channel  = instr[23:16];
assign wei_row      = instr[15:8];
assign wei_col      = instr[7:0];

assign uni_ready = A_ready;
assign wei_ready = B_ready;


//* A BUFFER
assign A_wen = uni_wen;
assign A_addr = uni_addr;
assign uni_data = A_DO;
assign A_DI = 0;


//* B BUFFER
assign B_wen = wei_wen;
assign B_addr = wei_addr;
assign wei_data = B_DO;
assign B_DI = 0;


//* O_uni BUFFER
assign O_uni_wen = DO_valid;
assign O_uni_addr = O_index;
assign O_uni_DI = DO_uni;

//* O_wei BUFFER
assign O_wei_wen = DO_valid;
assign O_wei_addr = O_index;
assign O_wei_DI = DO_wei;


endmodule








