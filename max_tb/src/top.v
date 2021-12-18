`include "define.v"

module TOP(
    clk,
    rst,
    nset,    
    start,
    done
);


input       clk;
input       rst;
input [9:0] row;
input       start;
output      done;



reg wen_A;
reg wen_B;

reg [`WORD_ADDR_BITS-1:0]   addr_A;
reg [`WORD_ADDR_BITS-1:0]   addr_B;

reg [`WORD_SIZE-1:0]        DI_A;
reg [`WORD_SIZE-1:0]        DI_B;


wire [`WORD_SIZE-1:0]        DO_A;
wire [`WORD_SIZE-1:0]        DO_B;

reg max_DI_valid;
wire max_DO_valid;
reg [`WORD_SIZE-1:0]        max_DI;
wire [`WORD_SIZE-1:0]       max_DO;



reg [3:0]                   cur_st;
reg [3:0]                   nxt_st;

reg [9:0]                   nset_cnt;
reg [9:0]                   out_cnt;
reg [3:0]                   row_i;

wire [9:0]                  output_dim;


always@(posedge clk or negedge rst) begin
    if(!rst) begin
        cur_st <= 4'd0;
        wen_A <= 1'b0;
        addr_A <= 0;
        max_DI_valid <= 1'b0;
        nset_cnt <= 10'd0;
        row_i <= 4'd0;
        done <= 1'b0;
    end else begin
        case(cur_st)
            4'd0: begin //* Initial state
                max_DI_valid <= 1'b0;
                addr_A <= 10'd0;
                wen_A <= 1'b0; //* Read-only
                nset_cnt <= 10'h3ff;
                row_i <= 4'd0;
                done <= 1'b0;
                cur_st <= (start) ? 4'd1 : 4'd0;
            end
            4'd1: begin //* Check data section, if it has data
                max_DI_valid <= 1'b0;
                nset_cnt <= (nset_cnt == nset-1) ? 10'd0 : nset_cnt + 10'd1;
                row_i <= 4'd0;
                cur_st <= (nset_cnt == nset-1) ? 4'd3 : 4'd2;
            end
            4'd2: begin //* Start to get data
                addr_A <= (nset_cnt << 4) + row_i;
                row_i <= (row_i == 4'd15) ? 0 : row_i + 4'd1;
                max_DI <= DO_A;
                max_DI_valid <= (row_i > 0) ? 1'b1 : 1'b0;
                cur_st <= (row_i == 4'd15) ? 4'd1 : 4'd2;
            end
            4'd3: begin //* No available data, should wait MAX to output data
                done <= (out_cnt == output_dim-1) ? 1'b1 : 1'b0;
                cur_st <= 4'd3;
            end
        endcase
    end
end

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        wen_B <= 1'b0;
        out_cnt <= 10'd0;
        addr_B <= 10'd0;
    end else begin
        if(max_DO_valid) begin
            wen_B <= 1'b1;
            DI_B <= max_DO;
            out_cnt <= (out_cnt == output_dim-1) ? 10'd0 : out_cnt + 10'd1;
            addr_B <= out_cnt;
        end else begin
            wen_B <= 1'b0;
        end
    end
end



    //* Your MAXP design
    // MAXP max_i(
    //     .clk        (clk            ),
    //     .rst        (rst            ),
    //     .DI_valid   (max_DI_valid   ),  
    //     .DI         (max_DI         ),
    //     .DO_valid   (max_DO_valid   ),
    //     .DO         (max_DO         )
    // );


    SRAM GBUFF_A(
        .clk    (clk        ),
        .rst    (rst        ),
        .wen    (wen_A      ),
        .addr   (addr_A     ),
        .DI     (DI_A       ),
        .DO     (DO_A       )
    );



    SRAM GBUFF_B(
        .clk    (clk        ),
        .rst    (rst        ),
        .wen    (wen_B      ),
        .addr   (addr_B     ),
        .DI     (DI_B       ),
        .DO     (DO_B       )      
    );


assign output_dim = nset >> 1;


endmodule