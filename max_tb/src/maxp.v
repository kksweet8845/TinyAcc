`include "define.v"
module MAXP(
    clk,
    rst,
    DI_valid,  
    DI,
    DO_valid,
    DO
);

input                           clk;
input                           rst;
input                           DI_valid;
input       [`WORD_SIZE-1:0]    DI;
output reg                      DO_valid;
output reg  [`WORD_SIZE-1:0]    DO;

reg         [`WORD_SIZE-1:0]    DO_buff [0:7];
reg         [1:0]               cur_st;
reg                             cur_st2;
integer                          i;
integer                          count;

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        DO_valid <= 1'b0;
        DO <= 128'd0;
        for (i=0; i < 8; i=i+1) begin
            DO_buff[i] <= 128'd0;
        end
        cur_st <= 2'd0;
        cur_st2 <= 1'b1;
        count <= 0;
    end else begin
        case(cur_st)
            2'd0: begin
                if(DI_valid) begin
                    DO_valid <= 1'b0;
                    DO <= 128'd0;
                    DO_buff[0] <= DI;
                    for (i=1; i < 8; i=i+1) begin
                        DO_buff[i] <= 128'd0;
                    end                
                    cur_st <= 2'd1;
                    cur_st2 <= 1'b1;
                    count <= 0;
                end
            end
            2'd1: begin
                if (!DI_valid) begin
                    cur_st <= 2'd2;
                    count <= 0;
                end else begin 
                    case(cur_st2)
                        1'b0: begin
                            DO_buff[count] <= DI;
                            cur_st2 <= 1'b1;
                        end
                        1'b1: begin
                            for (i=0; i < 16; i=i+1) begin 
                                if (DO_buff[count][8*(15-i) +: 8] < DI[8*(15-i) +: 8]) begin
                                    DO_buff[count][8*(15-i) +: 8] <= DI[8*(15-i) +: 8];
                                end
                            end
                            count <= count + 1;                  
                            cur_st2 <= 1'b0;   
                        end
                    endcase
                end      
            end
            2'd2: begin
                if (!DI_valid) begin
                    cur_st <= 2'd0;
                    DO_valid <= 1'b1;
                    DO <= DO_buff[count-1]; 
                end else begin
                    for (i=0; i < 16; i=i+1) begin 
                        if (DO_buff[count][8*(15-i) +: 8] < DI[8*(15-i) +: 8]) begin
                            DO_buff[count][8*(15-i) +: 8] <= DI[8*(15-i) +: 8];
                        end
                    end
                    case(cur_st2)
                        1'b0: begin
                            cur_st2 <= 1'b1;
                            if (count > 0) begin
                                DO_valid <= 1'b1;
                                DO <= DO_buff[count-1];                          
                            end
                        end
                        1'b1: begin
                            cur_st2 <= 1'b0;
                            count <= count + 1;
                            DO_valid <= 1'b0;
                        end
                    endcase
                end
            end
        endcase
    end
end

endmodule
