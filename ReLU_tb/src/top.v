`include "define.v"
module TOP(
    clk,
    rst,
    n,
    start,
    done
);


input           clk;
input           rst;
input [9:0]     n;
input           start;
output reg      done;


reg wen_A;
reg wen_B;

wire [`WORD_ADDR_BITS-1:0]  addr_A;
wire [`WORD_ADDR_BITS-1:0]  addr_B;

reg [`WORD_SIZE-1:0]        DI_A;
reg [`WORD_SIZE-1:0]        DI_B;


wire [`WORD_SIZE-1:0]       DO_A;
wire [`WORD_SIZE-1:0]       DO_B;


reg                         relu_DI_valid;
wire [`WORD_SIZE-1:0]       relu_DI;

wire                        relu_DO_valid;
wire [`WORD_SIZE-1:0]       relu_DO;


reg [3:0] cur_st;

reg [`WORD_ADDR_BITS-1:0]   DI_index;
reg [`WORD_ADDR_BITS-1:0]   DO_index;

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        cur_st <= 4'd0;
        DI_A <= 0;
        done <= 1'b0;
        wen_A <= 1'b0;
        DI_index <= 10'h3ff;
        relu_DI_valid <= 1'b0;
    end else begin
        case(cur_st)
            4'd0: begin //* Initial state
                done <= 1'b0;
                wen_A <= 1'b0;
                DI_index <= 10'd0;
                cur_st <= (start) ? 4'd1 : 4'd0;
                relu_DI_valid <= 1'b0;
            end
            4'd1: begin //* start to output data
                wen_A <= 1'b0;
                DI_index <= (DI_index == n-1) ? 10'd0 : DI_index + 10'd1;
                relu_DI_valid <= 1'b1;
                cur_st <= (DI_index == n-1) ? 4'd2 : 4'd1;
            end
            4'd2: begin //* no data available
                relu_DI_valid <= 1'b0;
                done <= (DO_index == n-1) ? 1'b1 : 1'b0;
                cur_st <= 4'd2;
            end
        endcase
    end
end

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        wen_B <= 1'b0;
        DO_index <= 10'h3ff;
    end else begin
        if(relu_DO_valid) begin
            wen_B <= 1'b1;
            DI_B <= relu_DO;
            DO_index <= (DO_index == n-1) ? 10'd0 : DO_index + 10'd1;
        end else begin
            wen_B <= 1'b0;
        end
    end 
end


assign addr_A = DI_index;
assign addr_B = DO_index;

assign relu_DI = DO_A;


    //* Your ReLu design
    // ReLU relu_i(
    //     .clk        (clk            ),
    //     .rst        (rst            ),
    //     .DI_valid   (relu_DI_valid  ),
    //     .DI         (relu_DI        ),
    //     .DO_valid   (relu_DO_valid  ),
    //     .DO         (relu_DO        )
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

endmodule