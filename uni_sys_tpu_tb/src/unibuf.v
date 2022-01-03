`include "define.v"
module UniBuf(
    clk,
    rst,
    //* Config unibuffer
    config_valid,
    op,
    A_src_addr,
    A_channel,
    A_row,
    A_col,
    B_src_addr,
    B_channel,
    B_row,
    B_col,
    ack,
    //* SRAM
    A_wen,
    A_addr,
    A_DI,
    A_DO,
    B_wen,
    B_addr,
    B_DI,
    B_DO,
    //* Systolic I/O
    // sys_op,
    // sys_uni_src_addr,
    // sys_uni_channel,
    // sys_uni_row,
    // sys_uni_col,
    // sys_wei_src_addr,
    // sys_wei_channel,
    // sys_wei_row,
    // sys_wei_col,
    // sys_ack,
    sys_done,
    sys_uni_ready, //* port for systolic to fetch data
    sys_uni_wen,
    sys_uni_addr,
    sys_uni_data,
    sys_wei_ready,
    sys_wei_wen,
    sys_wei_addr,
    sys_wei_data
);


input                                   clk;
input                                   rst;

//* unified buffer
input                                   config_valid;
input       [2:0]                       op;
input       [`WORD_ADDR_BITS-1:0]       A_src_addr;
input       [`DATA_MAX_BITS-1:0]        A_channel;
input       [`DATA_MAX_BITS-1:0]        A_row;
input       [`DATA_MAX_BITS-1:0]        A_col;
input       [`WORD_ADDR_BITS-1:0]       B_src_addr;
input       [`DATA_MAX_BITS-1:0]        B_channel;
input       [`DATA_MAX_BITS-1:0]        B_row;
input       [`DATA_MAX_BITS-1:0]        B_col;
output reg                              ack;

output                                  A_wen;
output      [`WORD_ADDR_BITS-1:0]       A_addr;
input       [`WORD_SIZE-1:0]            A_DI;
output      [`WORD_SIZE-1:0]            A_DO;


output                                  B_wen;
output      [`WORD_ADDR_BITS-1:0]       B_addr;
input       [`WORD_SIZE-1:0]            B_DI;
output      [`WORD_SIZE-1:0]            B_DO;

//* systolic I/O
// output      [2:0]                       sys_op;
// output      [`WORD_ADDR_BITS-1:0]       sys_uni_src_addr;
// output      [`DATA_MAX_BITS-1:0]        sys_uni_channel;
// output      [`DATA_MAX_BITS-1:0]        sys_uni_row;
// output      [`DATA_MAX_BITS-1:0]        sys_uni_col;

// output      [`WORD_ADDR_BITS-1:0]       sys_wei_src_addr;
// output      [`DATA_MAX_BITS-1:0]        sys_wei_channel;
// output      [`DATA_MAX_BITS-1:0]        sys_wei_row;
// output      [`DATA_MAX_BITS-1:0]        sys_wei_col;

// input                                   sys_ack;
input                                   sys_done; //* return from central controller

output                                  sys_uni_ready;
input                                   sys_uni_wen;
input       [`WORD_ADDR_BITS-1:0]       sys_uni_addr;
output      [`WORD_SIZE-1:0]            sys_uni_data;

output                                  sys_wei_ready;
input                                   sys_wei_wen;
input       [`WORD_ADDR_BITS-1:0]       sys_wei_addr;
output      [`WORD_SIZE-1:0]            sys_wei_data;


wire                                    uni_wen;
wire        [`WORD_ADDR_BITS-1:0]       uni_addr;
wire        [`WORD_SIZE-1:0]            uni_DI;
wire        [`WORD_SIZE-1:0]            uni_DO;

wire                                    wei_wen;
wire        [`WORD_ADDR_BITS-1:0]       wei_addr;
wire        [`WORD_SIZE-1:0]            wei_DI;
wire        [`WORD_SIZE-1:0]            wei_DO;

reg         [`WORD_ADDR_BITS-1:0]       A_src_addr_reg;
reg         [`DATA_MAX_BITS-1:0]        A_channel_reg;
reg         [`DATA_MAX_BITS-1:0]        A_row_reg;
reg         [`DATA_MAX_BITS-1:0]        A_col_reg;


reg         [`WORD_ADDR_BITS-1:0]       B_src_addr_reg;
reg         [`DATA_MAX_BITS-1:0]        B_channel_reg;
reg         [`DATA_MAX_BITS-1:0]        B_row_reg;
reg         [`DATA_MAX_BITS-1:0]        B_col_reg;

reg         [4:0]                       cur_st;
reg                                     op_reg;
reg                                     src_sel;

reg         [`DATA_MAX_BITS-1:0]        row_ksize_reg;
reg         [`DATA_MAX_BITS-1:0]        col_ksize_reg;

wire        [`WORD_ADDR_BITS-1:0]       write_addr;
wire        [`WORD_ADDR_BITS-1:0]       fetch_addr;
wire                                    config_op;
wire                                    conv_op;
wire                                    mat_op;


//* Conv Ctrl
reg                                      conv_ctrl_op_valid;
reg     [2:0]                            conv_ctrl_op;
wire                                     conv_ctrl_ack;
wire                                     conv_ctrl_data_NA;
reg     [`DATA_MAX_BITS-1:0]             conv_ctrl_channel;
reg     [`DATA_MAX_BITS-1:0]             conv_ctrl_row;
reg     [`DATA_MAX_BITS-1:0]             conv_ctrl_col;
reg     [`DATA_MAX_BITS-1:0]             conv_ctrl_row_ksize;
reg     [`DATA_MAX_BITS-1:0]             conv_ctrl_col_ksize;
wire                                     conv_ctrl_fetch_wen;
wire    [`WORD_ADDR_BITS-1:0]            conv_ctrl_fetch_addr;
wire    [`WORD_SIZE-1:0]                conv_ctrl_fetch_DI;
wire                                     conv_ctrl_write_wen;
wire    [`WORD_ADDR_BITS-1:0]            conv_ctrl_write_addr;
wire    [`WORD_SIZE-1:0]                conv_ctrl_write_DO;
wire                                     conv_ctrl_data_ready;

//* Max Ctrl
reg                                      uni_max_ctrl_op_valid;
reg     [2:0]                            uni_max_ctrl_op;
wire                                     uni_max_ctrl_ack;
wire                                     uni_max_ctrl_data_NA;
reg     [`DATA_MAX_BITS-1:0]             uni_max_ctrl_channel;
reg     [`DATA_MAX_BITS-1:0]             uni_max_ctrl_row;
reg     [`DATA_MAX_BITS-1:0]             uni_max_ctrl_col;
wire                                     uni_max_ctrl_fetch_wen;
wire    [`WORD_ADDR_BITS-1:0]            uni_max_ctrl_fetch_addr;
wire    [`WORD_SIZE-1:0]                 uni_max_ctrl_fetch_DI;
wire                                     uni_max_ctrl_write_wen;
wire    [`WORD_ADDR_BITS-1:0]            uni_max_ctrl_write_addr;
wire    [`WORD_SIZE-1:0]                 uni_max_ctrl_write_DO;
wire                                     uni_max_ctrl_data_ready;

reg                                      wei_max_ctrl_op_valid;
reg     [2:0]                            wei_max_ctrl_op;
wire                                     wei_max_ctrl_ack;
wire                                     wei_max_ctrl_data_NA;
reg     [`DATA_MAX_BITS-1:0]             wei_max_ctrl_channel;
reg     [`DATA_MAX_BITS-1:0]             wei_max_ctrl_row;
reg     [`DATA_MAX_BITS-1:0]             wei_max_ctrl_col;
wire                                     wei_max_ctrl_fetch_wen;
wire    [`WORD_ADDR_BITS-1:0]            wei_max_ctrl_fetch_addr;
wire    [`WORD_SIZE-1:0]                 wei_max_ctrl_fetch_DI;
wire                                     wei_max_ctrl_write_wen;
wire    [`WORD_ADDR_BITS-1:0]            wei_max_ctrl_write_addr;
wire    [`WORD_SIZE-1:0]                 wei_max_ctrl_write_DO;
wire                                     wei_max_ctrl_data_ready;





always@(posedge clk or negedge rst) begin
    if(!rst) begin
        ack <= 1'b0;
        A_src_addr_reg <= 0;
        A_channel_reg <= 0;
        A_row_reg <= 0;
        A_col_reg <= 0;
        B_src_addr_reg <= 0;
        B_channel_reg <= 0;
        B_row_reg <= 0;
        B_col_reg <= 0;
        cur_st <= 5'd0;
        op_reg <= 0;
        src_sel <= 0;
        row_ksize_reg <= 8'd3;
        col_ksize_reg <= 8'd3;
        conv_ctrl_op_valid <= 0;
        conv_ctrl_op <= 0;
        uni_max_ctrl_op_valid <= 0;
        uni_max_ctrl_op <= 0;
        wei_max_ctrl_op_valid <= 0;
        wei_max_ctrl_op <= 0;
    end else begin
        case(cur_st)
        5'd0: begin //* Initial state
            if(config_valid & config_op) begin
                A_src_addr_reg <= A_src_addr;
                A_channel_reg <= A_channel;
                A_row_reg <= A_row;
                A_col_reg <= A_col;
                B_src_addr_reg <= B_src_addr;
                B_channel_reg <= B_channel;
                B_row_reg <= B_row;
                B_col_reg <= B_col;
                ack <= 1'b1;
                op_reg <= 1'b0;
                cur_st <= 5'd0;
                src_sel <= 1'b0; //* fetching data
            end else if(config_valid & conv_op) begin
                op_reg <= 1'b1;
                ack <= 1'b1;
                cur_st <= 5'd1;
                src_sel <= 1'b0;
            end else if(config_valid & mat_op) begin
                op_reg <= 1'b0;
                ack <= 1'b1;
                cur_st <= 5'd1;
                src_sel <= 1'b0;
            end else begin
                ack <= 1'b0;
            end
        end
        5'd1: begin //* config conv ctrl
            if(op_reg == 1'b1) begin //* conv
                //* config conv
                conv_ctrl_op_valid <= 1'b1;
                conv_ctrl_op <= 3'b001;
                conv_ctrl_channel <= A_channel_reg;
                conv_ctrl_row     <= A_row_reg;
                conv_ctrl_col     <= A_col_reg;
                conv_ctrl_row_ksize <= row_ksize_reg;
                conv_ctrl_col_ksize <= col_ksize_reg;
                //* config weighting maxtrix
                wei_max_ctrl_op_valid <= 1'b1;
                wei_max_ctrl_op <= 3'b001;
                wei_max_ctrl_channel <= B_channel_reg;
                wei_max_ctrl_row     <= B_row_reg;
                wei_max_ctrl_col     <= B_col_reg;
            end else if(op_reg == 1'b0) begin //* matrix
                //* config uni matrix
                uni_max_ctrl_op_valid <= 1'b1;
                uni_max_ctrl_op <= 3'b001;
                uni_max_ctrl_channel <= A_channel_reg;
                uni_max_ctrl_row     <= A_row_reg;
                uni_max_ctrl_col     <= A_col_reg;
                //* config wei maxtrix
                wei_max_ctrl_op_valid <= 1'b1;
                wei_max_ctrl_op <= 3'b001;
                wei_max_ctrl_channel <= B_channel_reg;
                wei_max_ctrl_row     <= B_row_reg;
                wei_max_ctrl_col     <= B_col_reg;
            end
            ack <= 1'b0;
            cur_st <= 5'd2;
        end
        5'd2: begin //* wait for ack
            if(op_reg == 1'b1) begin
                conv_ctrl_op_valid <= 1'b0;
                wei_max_ctrl_op_valid <= 1'b0;
                cur_st <= (conv_ctrl_ack && wei_max_ctrl_ack) ? 5'd3 : 5'd2;
            end else if(op_reg == 1'b0) begin
                uni_max_ctrl_op_valid <= 1'b0;
                wei_max_ctrl_op_valid <= 1'b0;
                cur_st <= (uni_max_ctrl_ack && wei_max_ctrl_ack) ? 5'd3 : 5'd2;
            end
        end
        5'd3: begin //* start fetch data initially
            if(op_reg == 1'b1) begin
                conv_ctrl_op_valid <= 1'b1;
                conv_ctrl_op <= 3'b010;
                wei_max_ctrl_op_valid <= 1'b1;
                wei_max_ctrl_op <= 3'b011;
            end else if(op_reg == 1'b0) begin
                uni_max_ctrl_op_valid <= 1'b1;
                uni_max_ctrl_op <= 3'b011;
                wei_max_ctrl_op_valid <= 1'b1;
                wei_max_ctrl_op <= 3'b011;
            end
            cur_st <= 5'd4;
        end
        5'd4: begin //* wait for ack 2
            if(op_reg == 1'b1) begin
                conv_ctrl_op_valid <= 1'b0;
                wei_max_ctrl_op_valid <= 1'b0;
                cur_st <= (conv_ctrl_ack && wei_max_ctrl_ack) ? 5'd5 : 5'd4;
            end else if(op_reg == 1'b0) begin
                uni_max_ctrl_op_valid <= 1'b0;
                wei_max_ctrl_op_valid <= 1'b0;
                cur_st <= (uni_max_ctrl_ack && wei_max_ctrl_ack) ? 5'd5 : 5'd4;
            end
        end
        5'd5: begin //*  wait for fetch new data
            if(sys_done && op_reg == 1'b1 && !conv_ctrl_data_NA) begin //* fetch conv and max data
                conv_ctrl_op_valid <= 1'b1;
                conv_ctrl_op <= 3'b010;
                wei_max_ctrl_op_valid <= (B_channel_reg == 8'd1) ? 1'b0: 1'b1;
                wei_max_ctrl_op <= 3'b011;
                cur_st <= 5'd6;
                src_sel <= 1'b0;
            end else if(sys_done && op_reg == 1'b0 && !wei_max_ctrl_data_NA && !uni_max_ctrl_data_NA) begin //* fetch uni and wei data
                uni_max_ctrl_op_valid <= 1'b1;
                uni_max_ctrl_op <= 3'b011;
                wei_max_ctrl_op_valid <= 1'b1;
                wei_max_ctrl_op <= 3'b011;
                cur_st <= 5'd6;
                src_sel <= 1'b0;
            end else begin
                cur_st <= 5'd5;
                if(op_reg == 1'b1) begin
                    src_sel <= (conv_ctrl_data_ready && wei_max_ctrl_data_ready) ? 1'b1 : 1'b0;
                end else if(op_reg == 1'b0) begin
                    src_sel <= (uni_max_ctrl_data_ready && wei_max_ctrl_data_ready) ? 1'b1 : 1'b0;
                end
            end
        end
        5'd6: begin //* wait for ack 3
            if(op_reg == 1'b1) begin
                conv_ctrl_op_valid <= 1'b0;
                wei_max_ctrl_op_valid <= 1'b0;
                if(B_channel_reg == 8'd1) begin //* only conv ack
                    cur_st <= (conv_ctrl_ack) ? 5'd5 : 5'd6;
                end else begin
                    cur_st <= (conv_ctrl_ack && wei_max_ctrl_ack) ? 5'd5: 5'd6;
                end
            end else if(op_reg == 1'b0) begin
                uni_max_ctrl_op_valid <= 1'b0;
                wei_max_ctrl_op_valid <= 1'b0;
                cur_st <= (uni_max_ctrl_ack && wei_max_ctrl_ack) ? 5'd5: 5'd6;
            end
        end
        endcase
    end
end

//* A buffer
assign A_addr = (op_reg == 1'b1) ? A_src_addr_reg + conv_ctrl_fetch_addr : A_src_addr_reg + uni_max_ctrl_fetch_addr;
assign A_wen  = (op_reg == 1'b1) ? conv_ctrl_fetch_wen : uni_max_ctrl_fetch_wen;
assign A_DO   = 0;
assign conv_ctrl_fetch_DI = A_DI;
assign uni_max_ctrl_fetch_DI  = A_DI;

//* B buffer
assign B_addr = B_src_addr_reg + wei_max_ctrl_fetch_addr;
assign B_wen  = wei_max_ctrl_fetch_wen;
assign B_DO   = 0;
assign wei_max_ctrl_fetch_DI = B_DI;

//* WB buffer


//* uni buffer
assign uni_addr      = (src_sel) ? sys_uni_addr : (op_reg == 1'b1) ? conv_ctrl_write_addr : uni_max_ctrl_write_addr;
assign uni_wen       = (src_sel) ? sys_uni_wen  : (op_reg == 1'b1) ? conv_ctrl_write_wen  : uni_max_ctrl_write_wen;
assign uni_DI        = (src_sel) ? 0 : (op_reg == 1'b1) ? conv_ctrl_write_DO   : uni_max_ctrl_write_DO;
assign sys_uni_data  = (src_sel) ? uni_DO : 0;
assign sys_uni_ready = (op_reg == 1'b1) ? conv_ctrl_data_ready : uni_max_ctrl_data_ready;

//* wei buffer
assign wei_addr      = (src_sel) ? sys_wei_addr : wei_max_ctrl_write_addr;
assign wei_wen       = (src_sel) ? sys_wei_wen : wei_max_ctrl_write_wen;
assign wei_DI        = (src_sel) ? 0 : wei_max_ctrl_write_DO;
assign sys_wei_data  = (src_sel) ? wei_DO : 0;
assign sys_wei_ready = wei_max_ctrl_data_ready;




    ConvCtrl conv_ctrl_i(
        .clk                (clk                    ),
        .rst                (rst                    ),
        .ack                (conv_ctrl_ack          ),
        .op_valid           (conv_ctrl_op_valid     ),
        .op                 (conv_ctrl_op           ),
        .data_NA            (conv_ctrl_data_NA      ),
        .channel            (conv_ctrl_channel      ),
        .row                (conv_ctrl_row          ),
        .col                (conv_ctrl_col          ),
        .row_ksize          (conv_ctrl_row_ksize    ),
        .col_ksize          (conv_ctrl_col_ksize    ),
        .fetch_wen          (conv_ctrl_fetch_wen    ),
        .fetch_addr         (conv_ctrl_fetch_addr   ),
        .fetch_DI           (conv_ctrl_fetch_DI     ),
        .write_wen          (conv_ctrl_write_wen    ),
        .write_addr         (conv_ctrl_write_addr   ),
        .write_DO           (conv_ctrl_write_DO     ),
        .data_ready         (conv_ctrl_data_ready   )
    );


    MaxCtrl uni_max_ctrl_i(
        .clk                (clk                        ),
        .rst                (rst                        ),
        .op_valid           (uni_max_ctrl_op_valid      ),
        .op                 (uni_max_ctrl_op            ),
        .ack                (uni_max_ctrl_ack           ),
        .data_NA            (uni_max_ctrl_data_NA       ),
        .channel            (uni_max_ctrl_channel       ),
        .row                (uni_max_ctrl_row           ),
        .col                (uni_max_ctrl_col           ),
        .fetch_wen          (uni_max_ctrl_fetch_wen     ),
        .fetch_addr         (uni_max_ctrl_fetch_addr    ),
        .fetch_DI           (uni_max_ctrl_fetch_DI      ),
        .write_wen          (uni_max_ctrl_write_wen     ),
        .write_addr         (uni_max_ctrl_write_addr    ),
        .write_DO           (uni_max_ctrl_write_DO      ),
        .data_ready         (uni_max_ctrl_data_ready    )
    );

    MaxCtrl wei_max_ctrl_i(
        .clk                (clk                        ),
        .rst                (rst                        ),
        .ack                (wei_max_ctrl_ack           ),
        .op_valid           (wei_max_ctrl_op_valid      ),
        .op                 (wei_max_ctrl_op            ),
        .data_NA            (wei_max_ctrl_data_NA       ),
        .channel            (wei_max_ctrl_channel       ),
        .row                (wei_max_ctrl_row           ),
        .col                (wei_max_ctrl_col           ),
        .fetch_wen          (wei_max_ctrl_fetch_wen     ),
        .fetch_addr         (wei_max_ctrl_fetch_addr    ),
        .fetch_DI           (wei_max_ctrl_fetch_DI      ),
        .write_wen          (wei_max_ctrl_write_wen     ),
        .write_addr         (wei_max_ctrl_write_addr    ),
        .write_DO           (wei_max_ctrl_write_DO      ),
        .data_ready         (wei_max_ctrl_data_ready    )
    );

    SRAM uni_buf(
        .clk        (clk        ),
        .rst        (rst        ),
        .wen        (uni_wen    ),
        .addr       (uni_addr   ),
        .DI         (uni_DI     ),
        .DO         (uni_DO     )
    );

    SRAM wei_buf(
        .clk        (clk        ),
        .rst        (rst        ),
        .wen        (wei_wen    ),
        .addr       (wei_addr   ),
        .DI         (wei_DI     ),
        .DO         (wei_DO     )
    );

assign config_op = op == 3'b000 ? 1'b1 : 1'b0;
assign conv_op   = op == 3'b001 ? 1'b1 : 1'b0;
assign mat_op    = op == 3'b010 ? 1'b1 : 1'b0;

endmodule


