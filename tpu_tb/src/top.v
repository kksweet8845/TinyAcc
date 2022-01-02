`include "define.v"

module TOP(
    input clk,
    input rst,
    input start,
    input [7:0] m,
    input [7:0] k,
    input [7:0] n,
    output done
);



reg wr_en_a;
reg wr_en_b;
reg wr_en_out;


wire [`WORD_ADDR_BITS-1:0] addr_a;
wire [`WORD_ADDR_BITS-1:0] addr_b;
wire [`WORD_ADDR_BITS-1:0] addr_out;

wire [`WORD_SIZE-1:0] DI_a;
wire [`WORD_SIZE-1:0] DI_b;
wire [`WORD_SIZE-1:0] DI_out;


wire [`WORD_SIZE-1:0] DO_a;
wire [`WORD_SIZE-1:0] DO_b;
wire [`WORD_SIZE-1:0] DO_out;


wire valid;
wire tpu_out_valid_wire;
reg tpu_out_valid;
wire tpu_done;


reg tpu_in_valid;
reg [7:0] K;
reg [7:0] index_i;
reg [4:0] cur_st;

// reg [7:0] m_val;
// reg [7:0] k_val;
// reg [7:0] n_val;

reg done;

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        K <= 8'hff;
        wr_en_a <= 1'b0;
        wr_en_b <= 1'b0;
        wr_en_out <= 1'b0;
        cur_st <= 5'd0;
        done <= 1'b0;
        tpu_in_valid <= 1'b0;
    end else begin
        case(cur_st)
            5'd0: begin
                K <= 8'hff;
                wr_en_a <= 1'b0;
                wr_en_b <= 1'b0;
                wr_en_out <= 1'b0;
                done <= 1'b0;
                tpu_in_valid <= 1'b0;
                if(start) cur_st <= 5'd1;
            end
            5'd1: begin
                done <= 1'b0;
                tpu_in_valid <= (K == k-1) ? 1'b0 : 1'b1;
                K <= (K == k-1) ? 0 : K + 8'd1;
                wr_en_a <= 1'b0;
                wr_en_b <= 1'b0;
                wr_en_out <= 1'b1;
                cur_st <= (K == k-1) ? 5'd2 : 5'd1;   
            end
            5'd2: begin //* finish, start to output data
                done <= (tpu_done) ? 1'b1 : 1'b0;
                wr_en_a <= 1'b0;
                wr_en_b <= 1'b0;
                wr_en_out <= 1'b1;
            end
        endcase
    end
end

always@(negedge clk or negedge rst) begin
    if(!rst) begin
        index_i <= 8'hff;
    end else begin
        if(tpu_out_valid) begin
            index_i <= (index_i == m-1) ? 8'd0 : index_i + 8'd1;
        end
    end
end

always@(tpu_out_valid_wire) begin
    tpu_out_valid <= tpu_out_valid_wire;
end


assign addr_a = {2'b00, K+8'd1};
assign addr_b = {2'b00, K+8'd1};
assign addr_out = {2'b00, index_i};


    //TODO Should not aware of the matrix dimension 
    TPU tpu_i(
        .clk        (clk               ),
        .rst        (rst               ),
        .in_valid   (tpu_in_valid      ),
        .mat_DI     (DO_a              ),
        .wei_DI     (DO_b              ),
        .out_valid  (tpu_out_valid_wire),
        .DO         (DI_out            ),
        .done       (tpu_done          )
    );


    SRAM GBUFF_A(
        .clk    (clk        ),
        .rst    (rst        ),
        .wen    (wr_en_a    ),
        .addr   (addr_a     ),
        .DI     (DI_a       ),
        .DO     (DO_a       )    
    );


    SRAM GBUFF_B(
        .clk    (clk        ),
        .rst    (rst        ),
        .wen    (wr_en_b    ),
        .addr   (addr_b     ),
        .DI     (DI_b       ),
        .DO     (DO_b       )
    );


    SRAM GBUFF_OUT(
        .clk    (clk        ),
        .rst    (rst        ),
        .wen    (wr_en_out  ),
        .addr   (addr_out   ),
        .DI     (DI_out     ),
        .DO     (DO_out     )
    );




endmodule