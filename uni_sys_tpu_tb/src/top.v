`include "define.v"
module TOP(
    clk,
    rst,
    instr_valid,
    instr,
    data_total,
    ack,
    done
);

input clk;
input rst;
input instr_valid;
input [104:0] instr;
input [`WORD_ADDR_BITS-1:0] data_total;
output ack;
output reg done;


wire                                config_valid;
wire    [2:0]                       instr_op;
wire    [`WORD_ADDR_BITS-1:0]       WB_src_addr;
wire    [`DATA_MAX_BITS-1:0]        WB_channel;
wire    [`DATA_MAX_BITS-1:0]        WB_row;
wire    [`DATA_MAX_BITS-1:0]        WB_col;
wire    [`WORD_ADDR_BITS-1:0]       A_src_addr;
wire    [`DATA_MAX_BITS-1:0]        A_channel;
wire    [`DATA_MAX_BITS-1:0]        A_row;
wire    [`DATA_MAX_BITS-1:0]        A_col;
wire    [`WORD_ADDR_BITS-1:0]       B_src_addr;
wire    [`DATA_MAX_BITS-1:0]        B_channel;
wire    [`DATA_MAX_BITS-1:0]        B_row;
wire    [`DATA_MAX_BITS-1:0]        B_col;

//* Main ctrol
wire                                main_ctrl_config_valid;
wire    [2:0]                       main_ctrl_op;
wire    [`WORD_ADDR_BITS-1:0]       main_ctrl_WB_src_addr;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_WB_channel;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_WB_row;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_WB_col;
wire    [`WORD_ADDR_BITS-1:0]       main_ctrl_A_src_addr;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_A_channel;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_A_row;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_A_col;
wire    [`WORD_ADDR_BITS-1:0]       main_ctrl_B_src_addr;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_B_channel;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_B_row;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_B_col;
wire                                main_ctrl_ack;
wire                                main_ctrl_done;

wire                                main_ctrl_uni_config_valid;
wire    [2:0]                       main_ctrl_uni_op;
wire    [`WORD_ADDR_BITS-1:0]       main_ctrl_uni_A_src_addr;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_uni_A_channel;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_uni_A_row;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_uni_A_col;
wire    [`WORD_ADDR_BITS-1:0]       main_ctrl_uni_B_src_addr;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_uni_B_channel;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_uni_B_row;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_uni_B_col;
wire                                main_ctrl_uni_ack;

wire                                main_ctrl_sys_config_valid;
wire    [2:0]                       main_ctrl_sys_op;
wire    [`WORD_ADDR_BITS-1:0]       main_ctrl_sys_uni_src_addr;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_sys_uni_channel;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_sys_uni_row;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_sys_uni_col;
wire    [`WORD_ADDR_BITS-1:0]       main_ctrl_sys_wei_src_addr;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_sys_wei_channel;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_sys_wei_row;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_sys_wei_col;
wire                                main_ctrl_sys_ack;
wire                                main_ctrl_sys_done;

wire                                main_ctrl_wb_config_valid;
wire    [2:0]                       main_ctrl_wb_op;
wire    [`WORD_ADDR_BITS-1:0]       main_ctrl_wb_src_addr;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_wb_channel;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_wb_row;
wire    [`DATA_MAX_BITS-1:0]        main_ctrl_wb_col;
wire                                main_ctrl_wb_ack;
wire                                main_ctrl_wb_done;

//* Unibuf
wire                                unibuf_config_valid;
wire    [2:0]                       unibuf_op;
wire    [`WORD_ADDR_BITS-1:0]       unibuf_A_src_addr;
wire    [`DATA_MAX_BITS-1:0]        unibuf_A_channel;
wire    [`DATA_MAX_BITS-1:0]        unibuf_A_row;
wire    [`DATA_MAX_BITS-1:0]        unibuf_A_col;
wire    [`WORD_ADDR_BITS-1:0]       unibuf_B_src_addr;
wire    [`DATA_MAX_BITS-1:0]        unibuf_B_channel;
wire    [`DATA_MAX_BITS-1:0]        unibuf_B_row;
wire    [`DATA_MAX_BITS-1:0]        unibuf_B_col;
wire                                unibuf_ack;

wire                                unibuf_A_wen;
wire    [`WORD_ADDR_BITS-1:0]       unibuf_A_addr;
wire    [`WORD_SIZE-1:0]            unibuf_A_DI;
wire    [`WORD_SIZE-1:0]            unibuf_A_DO;
wire                                unibuf_B_wen;
wire    [`WORD_ADDR_BITS-1:0]       unibuf_B_addr;
wire    [`WORD_SIZE-1:0]            unibuf_B_DI;
wire    [`WORD_SIZE-1:0]            unibuf_B_DO;
wire                                unibuf_sys_done;
wire                                unibuf_sys_uni_ready;
wire                                unibuf_sys_uni_wen;
wire    [`WORD_ADDR_BITS-1:0]       unibuf_sys_uni_addr;
wire    [`WORD_SIZE-1:0]            unibuf_sys_uni_data;
wire                                unibuf_sys_wei_ready;
wire                                unibuf_sys_wei_wen;
wire    [`WORD_ADDR_BITS-1:0]       unibuf_sys_wei_addr;
wire    [`WORD_SIZE-1:0]            unibuf_sys_wei_data;

//* systolic array
wire                                syslic_config_valid;
wire    [2:0]                       syslic_op;
wire    [`WORD_ADDR_BITS-1:0]       syslic_uni_src_addr;
wire    [`DATA_MAX_BITS-1:0]        syslic_uni_channel;
wire    [`DATA_MAX_BITS-1:0]        syslic_uni_row;
wire    [`DATA_MAX_BITS-1:0]        syslic_uni_col;
wire    [`WORD_ADDR_BITS-1:0]       syslic_wei_src_addr;
wire    [`DATA_MAX_BITS-1:0]        syslic_wei_channel;
wire    [`DATA_MAX_BITS-1:0]        syslic_wei_row;
wire    [`DATA_MAX_BITS-1:0]        syslic_wei_col;
wire                                syslic_ack;
wire                                syslic_done;
wire                                syslic_uni_ready;
wire                                syslic_uni_wen;
wire    [`WORD_ADDR_BITS-1:0]       syslic_uni_addr;
wire    [`WORD_SIZE-1:0]            syslic_uni_data;
wire                                syslic_wei_ready;
wire                                syslic_wei_wen;
wire    [`WORD_ADDR_BITS-1:0]       syslic_wei_addr;
wire    [`WORD_SIZE-1:0]            syslic_wei_data;
wire                                syslic_DO_valid;
wire    [`WORD_SIZE-1:0]            syslic_DO_uni;
wire    [`WORD_SIZE-1:0]            syslic_DO_wei;

//* A buf
wire                                A_buf_rd_valid;
wire    [`WORD_ADDR_BITS-1:0]       A_buf_rd_addr;
wire    [`WORD_SIZE-1:0]            A_buf_DO;
wire                                A_buf_wr_valid;
wire    [`WORD_ADDR_BITS-1:0]       A_buf_wr_addr;
wire    [`WORD_SIZE-1:0]            A_buf_DI;

//* B buf
wire    [`WORD_ADDR_BITS-1:0]       B_buf_addr;
wire                                B_buf_wen;
wire    [`WORD_SIZE-1:0]            B_buf_DI;
wire    [`WORD_SIZE-1:0]            B_buf_DO;


reg                                 OUT_wen;
reg     [`WORD_ADDR_BITS-1:0]       OUT_addr;
reg     [`WORD_SIZE-1:0]            OUT_uni_data;
reg     [`WORD_SIZE-1:0]            OUT_wei_data;
wire    [`WORD_SIZE-1:0]            OUT_uni_DO;
wire    [`WORD_SIZE-1:0]            OUT_wei_DO;





    //* Decoder 
    Decoder decoder_i(
        .instr_valid        (instr_valid        ),
        .instr              (instr              ),
        .valid              (config_valid       ),
        .op                 (instr_op           ),
        .WB_src_addr        (WB_src_addr        ),
        .WB_channel         (WB_channel         ),
        .WB_row             (WB_row             ),
        .WB_col             (WB_col             ),
        .A_src_addr         (A_src_addr         ),
        .A_channel          (A_channel          ),
        .A_row              (A_row              ),
        .A_col              (A_col              ),
        .B_src_addr         (B_src_addr         ),
        .B_channel          (B_channel          ),
        .B_row              (B_row              ),
        .B_col              (B_col              )
    );

    //* Main controller
    MainCtrl main_ctrl_i(
        .clk                (clk                        ),
        .rst                (rst                        ),
        .config_valid       (main_ctrl_config_valid     ),
        .op                 (main_ctrl_op               ),
        .WB_src_addr        (main_ctrl_WB_src_addr      ),
        .WB_channel         (main_ctrl_WB_channel       ),
        .WB_row             (main_ctrl_WB_row           ),
        .WB_col             (main_ctrl_WB_col           ),
        .A_src_addr         (main_ctrl_A_src_addr       ),
        .A_channel          (main_ctrl_A_channel        ),
        .A_row              (main_ctrl_A_row            ),
        .A_col              (main_ctrl_A_col            ),
        .B_src_addr         (main_ctrl_B_src_addr       ),
        .B_channel          (main_ctrl_B_channel        ),
        .B_row              (main_ctrl_B_row            ),
        .B_col              (main_ctrl_B_col            ),
        .ack                (main_ctrl_ack              ),
        .done               (main_ctrl_done             ),
        .uni_config_valid   (main_ctrl_uni_config_valid ),
        .uni_op             (main_ctrl_uni_op           ),
        .uni_A_src_addr     (main_ctrl_uni_A_src_addr   ),
        .uni_A_channel      (main_ctrl_uni_A_channel    ),
        .uni_A_row          (main_ctrl_uni_A_row        ),
        .uni_A_col          (main_ctrl_uni_A_col        ),
        .uni_B_src_addr     (main_ctrl_uni_B_src_addr   ),
        .uni_B_channel      (main_ctrl_uni_B_channel    ),
        .uni_B_row          (main_ctrl_uni_B_row        ),
        .uni_B_col          (main_ctrl_uni_B_col        ),
        .uni_ack            (main_ctrl_uni_ack          ),
        .sys_config_valid   (main_ctrl_sys_config_valid ),
        .sys_op             (main_ctrl_sys_op           ),
        .sys_uni_src_addr   (main_ctrl_sys_uni_src_addr   ),
        .sys_uni_channel    (main_ctrl_sys_uni_channel    ),
        .sys_uni_row        (main_ctrl_sys_uni_row        ),
        .sys_uni_col        (main_ctrl_sys_uni_col        ),
        .sys_wei_src_addr   (main_ctrl_sys_wei_src_addr   ),
        .sys_wei_channel    (main_ctrl_sys_wei_channel    ),
        .sys_wei_row        (main_ctrl_sys_wei_row        ),
        .sys_wei_col        (main_ctrl_sys_wei_col        ),
        .sys_ack            (main_ctrl_sys_ack          ),
        .sys_done           (main_ctrl_sys_done         ),
        .wb_config_valid    (main_ctrl_wb_config_valid  ),
        .wb_op              (main_ctrl_wb_op            ),
        .wb_channel         (main_ctrl_wb_channel       ),
        .wb_row             (main_ctrl_wb_row           ),
        .wb_col             (main_ctrl_wb_col           ),
        .wb_ack             (main_ctrl_wb_ack           ),
        .wb_done            (main_ctrl_wb_done          )
    );


    //* Unified Buffer
    UniBuf unibuf_i(
        .clk                (clk                        ),
        .rst                (rst                        ),
        .config_valid       (unibuf_config_valid        ),
        .op                 (unibuf_op                  ),
        .A_src_addr         (unibuf_A_src_addr          ),
        .A_channel          (unibuf_A_channel           ),
        .A_row              (unibuf_A_row               ),
        .A_col              (unibuf_A_col               ),
        .B_src_addr         (unibuf_B_src_addr          ),
        .B_channel          (unibuf_B_channel           ),
        .B_row              (unibuf_B_row               ),
        .B_col              (unibuf_B_col               ),
        .ack                (unibuf_ack                 ),
        .A_wen              (unibuf_A_wen               ),
        .A_addr             (unibuf_A_addr              ),
        .A_DI               (unibuf_A_DI                ),
        .A_DO               (unibuf_A_DO                ),
        .B_wen              (unibuf_B_wen               ),
        .B_addr             (unibuf_B_addr              ),
        .B_DI               (unibuf_B_DI                ),
        .B_DO               (unibuf_B_DO                ),
        .sys_done           (unibuf_sys_done            ),
        .sys_uni_ready      (unibuf_sys_uni_ready       ),
        .sys_uni_wen        (unibuf_sys_uni_wen         ),
        .sys_uni_addr       (unibuf_sys_uni_addr        ),
        .sys_uni_data       (unibuf_sys_uni_data        ),
        .sys_wei_ready      (unibuf_sys_wei_ready       ),
        .sys_wei_wen        (unibuf_sys_wei_wen         ),
        .sys_wei_addr       (unibuf_sys_wei_addr        ),
        .sys_wei_data       (unibuf_sys_wei_data        )
    );

    Systolic syslic_i(
        .clk                (clk                        ),
        .rst                (rst                        ),
        .op                 (syslic_op                  ),
        .config_valid       (syslic_config_valid        ),
        .uni_src_addr       (syslic_uni_src_addr        ),
        .uni_channel        (syslic_uni_channel         ),
        .uni_row            (syslic_uni_row             ),
        .uni_col            (syslic_uni_col             ),
        .wei_src_addr       (syslic_wei_src_addr        ),
        .wei_channel        (syslic_wei_channel         ),
        .wei_row            (syslic_wei_row             ),
        .wei_col            (syslic_wei_col             ),
        .ack                (syslic_ack                 ),
        .done               (syslic_done                ),
        .uni_ready          (syslic_uni_ready           ),
        .uni_wen            (syslic_uni_wen             ),
        .uni_addr           (syslic_uni_addr            ),
        .uni_data           (syslic_uni_data            ),
        .wei_ready          (syslic_wei_ready           ),
        .wei_wen            (syslic_wei_wen             ),
        .wei_addr           (syslic_wei_addr            ),
        .wei_data           (syslic_wei_data            ),
        .DO_valid           (syslic_DO_valid            ),
        .DO_uni             (syslic_DO_uni              ),
        .DO_wei             (syslic_DO_wei              )
    );


    SRAM_2 GBUFF_A(
        .clk                (clk                        ),
        .rst                (rst                        ),
        .rd_valid           (A_buf_rd_valid             ),
        .rd_addr            (A_buf_rd_addr              ),
        .DO                 (A_buf_DO                   ),
        .wr_valid           (A_buf_wr_valid             ),
        .wr_addr            (A_buf_wr_addr              ),
        .DI                 (A_buf_DI                   )
    );

    SRAM GBUFF_B(
        .clk                (clk                        ),
        .rst                (rst                        ),
        .wen                (B_buf_wen                  ),
        .addr               (B_buf_addr                 ),
        .DI                 (B_buf_DI                   ),
        .DO                 (B_buf_DO                   )
    );

    SRAM GBUFF_O_uni(
        .clk                (clk                        ),
        .rst                (rst                        ),
        .wen                (OUT_wen                    ),
        .addr               (OUT_addr                   ),
        .DI                 (OUT_uni_data               ),
        .DO                 (OUT_uni_DO                 )
    );

    SRAM GBUFF_O_wei(
        .clk                (clk                        ),
        .rst                (rst                        ),
        .wen                (OUT_wen                    ),
        .addr               (OUT_addr                   ),
        .DI                 (OUT_wei_data               ),
        .DO                 (OUT_wei_DO                 )
    );

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        OUT_wen <= 1'b0;
        OUT_addr <= 12'hfff;
        OUT_uni_data <= 0;
        OUT_wei_data <= 0;
        done <= 1'b0;
    end else begin
        if(syslic_DO_valid) begin
            OUT_wen <= 1'b1;
            OUT_addr <= (OUT_addr == 12'hfff) ? 10'd0 : OUT_addr + 10'd1; 
            OUT_uni_data <= syslic_DO_uni;
            OUT_wei_data <= syslic_DO_wei;
        end else begin
            OUT_wen <= 1'b0;
            done <= (OUT_addr == data_total - 1) ? 1'b1 : 1'b0;
        end
    end
end



assign ack                   = main_ctrl_ack;
// assign done                  = main_ctrl_done;


//* Main control
assign main_ctrl_config_valid = config_valid;
assign main_ctrl_op = instr_op;
assign main_ctrl_WB_src_addr = WB_src_addr;
assign main_ctrl_WB_channel  = WB_channel;
assign main_ctrl_WB_row      = WB_row;
assign main_ctrl_WB_col      = WB_col;
assign main_ctrl_A_src_addr  = A_src_addr;
assign main_ctrl_A_channel   = A_channel;
assign main_ctrl_A_row       = A_row;
assign main_ctrl_A_col       = A_col;
assign main_ctrl_B_src_addr  = B_src_addr;
assign main_ctrl_B_channel   = B_channel;
assign main_ctrl_B_row       = B_row;
assign main_ctrl_B_col       = B_col;

assign main_ctrl_uni_ack        = unibuf_ack;
assign main_ctrl_sys_ack        = syslic_ack;

assign main_ctrl_sys_done       = syslic_done;


//* Uni buf
assign unibuf_config_valid      = main_ctrl_uni_config_valid;
assign unibuf_op                = main_ctrl_uni_op;
assign unibuf_A_src_addr        = main_ctrl_uni_A_src_addr;
assign unibuf_A_channel         = main_ctrl_uni_A_channel;
assign unibuf_A_row             = main_ctrl_uni_A_row;
assign unibuf_A_col             = main_ctrl_uni_A_col;
assign unibuf_B_src_addr        = main_ctrl_uni_B_src_addr;
assign unibuf_B_channel         = main_ctrl_uni_B_channel;
assign unibuf_B_row             = main_ctrl_uni_B_row;
assign unibuf_B_col             = main_ctrl_uni_B_col;

assign unibuf_A_DI              = A_buf_DO;
assign unibuf_B_DI              = B_buf_DO;

assign unibuf_sys_done          = syslic_done;

assign unibuf_sys_uni_wen           = syslic_uni_wen;
assign unibuf_sys_uni_addr          = syslic_uni_addr;
assign unibuf_sys_wei_wen           = syslic_wei_wen;
assign unibuf_sys_wei_addr          = syslic_wei_addr;



//* Systolic
assign syslic_config_valid      = main_ctrl_sys_config_valid;
assign syslic_op                = main_ctrl_sys_op;
assign syslic_uni_src_addr      = main_ctrl_sys_uni_src_addr;
assign syslic_uni_channel       = main_ctrl_sys_uni_channel;
assign syslic_uni_row           = main_ctrl_sys_uni_row;
assign syslic_uni_col           = main_ctrl_sys_uni_col;
assign syslic_wei_src_addr      = main_ctrl_sys_wei_src_addr;
assign syslic_wei_channel       = main_ctrl_sys_wei_channel;
assign syslic_wei_row           = main_ctrl_sys_wei_row;
assign syslic_wei_col           = main_ctrl_sys_wei_col;

assign syslic_uni_ready         = unibuf_sys_uni_ready;
assign syslic_uni_data          = unibuf_sys_uni_data;
assign syslic_wei_ready         = unibuf_sys_wei_ready;
assign syslic_wei_data          = unibuf_sys_wei_data;


//* A buf
assign A_buf_rd_valid           = unibuf_A_wen;
assign A_buf_rd_addr            = unibuf_A_addr;


//* B buf
assign B_buf_wen                = unibuf_B_wen;
assign B_buf_addr               = unibuf_B_addr;


endmodule






