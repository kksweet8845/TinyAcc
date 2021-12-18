`include "define.v"
module TOP(
    clk,
    rst,
    n,
    start,
    done
);


input           clk,
input           rst,
input [9:0]     n;
input           start;
output reg      done;


reg wen_A;
reg wen_B;

reg [`WORD_ADDR_BITS-1:0]   addr_A;
reg [`WORD_ADDR_BITS-1:0]   addr_B;

reg [`WORD_SIZE-1:0]        DI_A;
reg [`WORD_SIZE-1:0]        DI_B;


wire [`WORD_SIZE-1:0]        DO_A;
wire [`WORD_SIZE-1:0]        DO_B;


reg                     relu_DI_valid;
reg [`WORD_SIZE-1:0]    relu_DI;

wire                    relu_DO_valid;
wire [`WORD_SIZE-1:0]   relu_DO;


reg [3:0] cur_st;

reg [`WORD_ADDR_BITS-1:0]   DI_index;
reg [`WORD_ADDR_BITS-1:0]   DO_index;

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        cur_st <= 4'd0;
        addr_A <= 10'd0;
        DI_A <= 0;
        done <= 1'b0;
        wen_A <= 1'b0;
        DI_index <= 10'h3ff;
    end else begin
        case(cur_st)
            4'd0: begin //* Initial state
                done <= 1'b0;
                wen_A <= 1'b0;
                DI_index <= 10'h3ff;
                cur_st <= (start) ? 4'd1 : 4'd0;
            end
            4'd1: begin //* start to output data
                addr_A <= DI_index;
                wen_A <= 1'b0;
                DI_index <= (DI_index == n-1) ? 10'd0 : DI_index + 10'd1;
                relu_DI_valid <= (DI_index > 0) ? 1'b1 : 1'b0;
                relu_DI <= DO_A;
                cur_st <= (DI_index == n-1) ? 4'd2 : 4'd1;
            end
            4'd2: begin //* no data available
                done <= (DO_index == n-1) ? 1'b1 : 1'b0;
                cur_st <= 4'd2;
            end
        endcase
    end
end

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        web_B <= 1'b0;
        DO_index <= 10'd0;
        addr_B <= 10'd0;
    end else begin
        if(relu_DO_valid) begin
            wen_B <= 1'b1;
            DI_B <= relu_DO;
            DO_index <= (DO_index == n-1) ? 10'd0 : DO_index + 10'd1;
            addr_B <= DO_index;
        end else begin
            wen_B <= 1'b0;
        end
    end 
end


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