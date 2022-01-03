`include "define.v"
module Data_Rotator(
    clk,
    rst,
    channel,
    DI_valid,
    DI,
    DO_valid,
    DO
);



input                   clk;
input                   rst;
input                   DI_valid;
input [`WORD_SIZE-1:0]  DI;
output                  DO_valid;
output [`WORD_SIZE-1:0] DO;


reg [`WORD_SIZE-1:0]    dbuf[0:7];
reg [4:0]               cur_st;
reg [4:0]               cnt;
integer                 i;


always@(posedge clk or negedge rst) begin
    if(!rst) begin
        cnt <= 5'd0;
        cur_st <= 5'd0;
        for(i=0;i<8;i=i+1) begin
            dbuf[i] <= 0;
        end
    end else begin
        case(cur_st) begin
            5'd0: begin //* wait for data
                if(DI_valid) begin
                    cnt <= (cnt == 5'd7) ? 5'd0 : cnt + 5'd1;
                    dbuf[cnt] <= DI;
                    cur_st <= (cnt == 5'd7) ? 5'd1: 5'd2;
                end
                DO_valid <= 1'b0;
            end
            5'd1: begin
                cnt <= (cnt == channel- 1) ? 5'd0 : cnt + 5'd1;
                cur_st <= (cnt == channel - 1) ? 5'd0 : 5'd1;
                DO_valid <= (cnt == channel - 1) ? 1'b1 : 1'b0;
                case(cnt)
                    5'd0: begin
                        DO <= {dbf[0][127:120], dbf[1][127:120], dbf[2][127:120], dbf[3][127:120], dbf[4][127:120], dbf[5][127:120], dbf[6][127:120], dbf[7][127:120], 64'd0};
                    end
                    5'd1: begin
                        DO <= {dbf[0][119:112], dbf[1][119:112], dbf[2][119:112], dbf[3][119:112], dbf[4][119:112], dbf[5][119:112], dbf[6][119:112], dbf[7][119:112], 64'd0};
                    end
                    5'd2: begin
                        DO <= {dbf[0][111:104], dbf[1][111:104], dbf[2][111:104], dbf[3][111:104], dbf[4][111:104], dbf[5][111:104], dbf[6][111:104], dbf[7][111:104], 64'd0};
                    end
                    5'd3: begin
                        DO <= {dbf[0][103:96], dbf[1][103:96], dbf[2][103:96], dbf[3][103:96], dbf[4][103:96], dbf[5][103:96], dbf[6][103:96], dbf[7][103:96], 64'd0};
                    end
                    5'd4: begin
                        DO <= {dbf[0][95:88], dbf[1][95:88], dbf[2][95:88], dbf[3][95:88], dbf[4][95:88], dbf[5][95:88], dbf[6][95:88], dbf[7][95:88], 64'd0};
                    end
                    5'd5: begin
                        DO <= {dbf[0][87:80], dbf[1][87:80], dbf[2][87:80], dbf[3][87:80], dbf[4][87:80], dbf[5][87:80], dbf[6][87:80], dbf[7][87:80], 64'd0};
                    end
                    5'd6: begin
                        DO <= {dbf[0][79:72], dbf[1][79:72], dbf[2][79:72], dbf[3][79:72], dbf[4][79:72], dbf[5][79:72], dbf[6][79:72], dbf[7][79:72], 64'd0};
                    end
                    5'7: begin
                        DO <= {dbf[0][71:64], dbf[1][71:64], dbf[2][71:64], dbf[3][71:64], dbf[4][71:64], dbf[5][71:64], dbf[6][71:64], dbf[7][71:64], 64'd0};
                    end
                    5'd8: begin
                        DO <= {dbf[0][63:56], dbf[1][63:56], dbf[2][63:56], dbf[3][63:56], dbf[4][63:56], dbf[5][63:56], dbf[6][63:56], dbf[7][63:56], 64'd0};
                    end
                    5'd9: begin
                        DO <= {dbf[0][55:48], dbf[1][55:48], dbf[2][55:48], dbf[3][55:48], dbf[4][55:48], dbf[5][55:48], dbf[6][55:48], dbf[7][55:48], 64'd0};
                    end
                    5'd10: begin
                        DO <= {dbf[0][47:40], dbf[1][47:40], dbf[2][47:40], dbf[3][47:40], dbf[4][47:40], dbf[5][47:40], dbf[6][47:40], dbf[7][47:40], 64'd0};
                    end
                    5'd11: begin
                        DO <= {dbf[0][39:32], dbf[1][39:32], dbf[2][39:32], dbf[3][39:32], dbf[4][39:32], dbf[5][39:32], dbf[6][39:32], dbf[7][39:32], 64'd0};
                    end
                    5'd12: begin
                        DO <= {dbf[0][31:24], dbf[1][31:24], dbf[2][31:24], dbf[3][31:24], dbf[4][31:24], dbf[5][31:24], dbf[6][31:24], dbf[7][31:24], 64'd0};
                    end
                    5'd13: begin
                        DO <= {dbf[0][23:16], dbf[1][23:16], dbf[2][23:16], dbf[3][23:16], dbf[4][23:16], dbf[5][23:16], dbf[6][23:16], dbf[7][23:16], 64'd0};
                    end
                    5'd14: begin
                        DO <= {dbf[0][15:8], dbf[1][15:8], dbf[2][15:8], dbf[3][15:8], dbf[4][15:8], dbf[5][15:8], dbf[6][15:8], dbf[7][15:8], 64'd0};
                    end
                    5'd15: begin
                        DO <= {dbf[0][7:0], dbf[1][7:0], dbf[2][7:0], dbf[3][7:0], dbf[4][7:0], dbf[5][7:0], dbf[6][7:0], dbf[7][7:0], 64'd0};
                    end
                endcase
            end
        end
    end
end





















endmodule