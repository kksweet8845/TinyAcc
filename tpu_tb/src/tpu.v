`include "define.v"
module TPU(
    clk,
    rst,
    in_valid,
    mat_DI,
    wei_DI,
    out_valid,
    DO,
    done
);

//Max Pipeline length = 16 (channel) * 9 (filter)
`define PL_LEN 144

input                 clk;
input                 rst;
input                 in_valid;
input      [127:0]    mat_DI;
input      [127:0]    wei_DI;
output reg             out_valid;
output reg  [127:0]    DO;
output reg             done;

wire        [127:0]     down_out            [0:15];
wire        [127:0]     sum                 [0:15];
reg         [127:0]     data_in;
reg         [127:0]     weight_in;
reg         [127:0]     data_pl             [0:`PL_LEN-1];
reg         [127:0]     weight_pl           [0:`PL_LEN-1];
reg                     cur_st1;
reg                     iv_neg;     //in_valid from positve state change to negative state
reg                     cur_st2;
reg                     cur_st3;
reg                     cur_st4;
integer                  pl_count;
integer                  pl_count2;
integer                  output_count;
integer                  cycle_count;
integer                  i;

<<<<<<< HEAD

always@(posedge in_valid) begin
    pl_count <= 0;
    pl_count2 <= 0;
    sa_in_valid <= 1'b1;
    for(i=0; i< `MATRIX_A_COL+`MATRIX_A_ROW-1; i=i+1) begin
        data_pl[i] <= 128'd0;
        weight_pl[i] <= 128'd0;
    end 
//-------------------------------------------
    out_valid <= 1'b0;
    done <= 1'b0;
    output_count <= 0;
    cycle_count_vaild <= 1'b1;
    cycle_count <= 0;
end
=======
>>>>>>> d04e660d0e12c1a217f16e2322ba3074ab6eb1d0


//------------------------------ Input Pipeline ------------------------------//

always@(posedge clk or negedge rst) begin
    if (!rst) begin
         for(i=0; i < `PL_LEN; i=i+1) begin
            data_pl[i] <= 128'd0;
            weight_pl[i] <= 128'd0;
         end
         cur_st1 <= 1'b0;
         iv_neg <= 1'b0;
         pl_count <= 0;
         //---------------------------------------------------
         data_in <= 128'd0;
         weight_in <= 128'd0;
         cur_st2 <= 1'b0;
         pl_count2 <= 0;
    end else begin
        case(cur_st1)
            1'b0: begin
                if (in_valid) begin
                    for (i=0; i < 16; i=i+1) begin
                        data_pl[i+pl_count][8*(15-i) +: 8] <= mat_DI[8*(15-i) +: 8];
                        weight_pl[i+pl_count][8*(15-i) +: 8] <= wei_DI[8*(15-i) +: 8];
                    end
                    pl_count <= pl_count + 1;
                    iv_neg <= 1'b1;
                end else begin
                    if (iv_neg) begin
                        cur_st1 <= 1'b1;
                        iv_neg <= 1'b0;
                    end
                end
            end
            1'b1: begin
                if (done) begin
                    for(i=0; i < pl_count+16-1; i=i+1) begin
                        data_pl[i] <= 128'd0;
                        weight_pl[i] <= 128'd0;
                    end
                    pl_count <= 0;
                    cur_st1 <= 1'b0;
                end
            end
        endcase
        //---------------------------------------------------
        case(cur_st2) 
            1'b0: begin
                if (in_valid) begin
                    cur_st2 <= 1'b1;
                end
            end
            1'b1: begin
                if (pl_count2 == pl_count+16-2) begin
                    data_in <= 128'd0;
                    weight_in <= 128'd0;
                    cur_st2 <= 1'b0;
                    pl_count2 <= 0;
                end else begin
                    data_in <= data_pl[pl_count2];
                    weight_in <= weight_pl[pl_count2];
                    pl_count2 <= pl_count2+1;
                end              
            end
        endcase
    end
end

//------------------------------ Output Pipeline ------------------------------//

always@(posedge clk or negedge rst) begin
    if (!rst) begin
        out_valid <= 1'b0;
        cur_st3 <= 1'b0;
        cycle_count <= 0;
    end else begin 
        case(cur_st3) 
            1'b0: begin
                if (in_valid) begin
                    out_valid <= 1'b0;                  
                    cur_st3 <= 1'b1;
                end
            end
            1'b1: begin
                out_valid <= (cycle_count == pl_count+16-1) ? 1'b1 : 1'b0;               
                cur_st3 <= (cycle_count == pl_count+16-1) ? 1'b0 : 1'b1;
                cycle_count <= (cycle_count == pl_count+16-1) ? 0 : cycle_count+1;
            end
        endcase
    end
end

always@(negedge clk or negedge rst) begin
    if (!rst) begin
        DO <= 128'd0;
        done <= 1'b0;
        cur_st4 <= 1'b0;
        output_count <= 0;
    end else begin
        case(cur_st4)
            1'b0: begin
                DO <= 128'd0;
                if (in_valid) begin
                    done <= 1'b0;
                    cur_st4 <= 1'b1;
                end
            end
            1'b1: begin
                if (out_valid) begin
                    DO <= sum[output_count];
                    done <= (output_count == 16-1) ? 1'b1 : 1'b0;
                    cur_st4 <= (output_count == 16-1) ? 1'b0 : 1'b1;
                    output_count <= (output_count == 16-1) ? 0 : output_count+1;
                end
            end
        endcase
    end
end

//------------------------------ Systolic Array ------------------------------//

//--------  ROW 1 --------//
    ROW_PE row1(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[127:120]),
        .up_in(weight_in),
        .down_out(down_out[0]),
        .sum(sum[0])
    );

//--------  ROW 2 --------//
    ROW_PE row2(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[119:112]),
        .up_in(down_out[0]),
        .down_out(down_out[1]),
        .sum(sum[1])
    );

//--------  ROW 3 --------//
    ROW_PE row3(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[111:104]),
        .up_in(down_out[1]),
        .down_out(down_out[2]),
        .sum(sum[2])
    );   

//--------  ROW 4 --------//
    ROW_PE row4(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[103:96]),
        .up_in(down_out[2]),
        .down_out(down_out[3]),
        .sum(sum[3])
    );

//--------  ROW 5 --------//
    ROW_PE row5(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[95:88]),
        .up_in(down_out[3]),
        .down_out(down_out[4]),
        .sum(sum[4])
    );

//--------  ROW 6 --------//
    ROW_PE row6(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[87:80]),
        .up_in(down_out[4]),
        .down_out(down_out[5]),
        .sum(sum[5])
    ); 

//--------  ROW 7 --------//
    ROW_PE row7(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[79:72]),
        .up_in(down_out[5]),
        .down_out(down_out[6]),
        .sum(sum[6])
    );
    
//--------  ROW 8 --------//
    ROW_PE row8(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[71:64]),
        .up_in(down_out[6]),
        .down_out(down_out[7]),
        .sum(sum[7])
    );
    
//--------  ROW 9 --------//
    ROW_PE row9(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[63:56]),
        .up_in(down_out[7]),
        .down_out(down_out[8]),
        .sum(sum[8])
    ); 
  
//--------  ROW 10 --------//
    ROW_PE row10(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[55:48]),
        .up_in(down_out[8]),
        .down_out(down_out[9]),
        .sum(sum[9])
    );
 
//--------  ROW 11 --------//
    ROW_PE row11(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[47:40]),
        .up_in(down_out[9]),
        .down_out(down_out[10]),
        .sum(sum[10])
    );
    
//--------  ROW 12 --------//
    ROW_PE row12(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[39:32]),
        .up_in(down_out[10]),
        .down_out(down_out[11]),
        .sum(sum[11])
    );   
    
//--------  ROW 13 --------//
    ROW_PE row13(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[31:24]),
        .up_in(down_out[11]),
        .down_out(down_out[12]),
        .sum(sum[12])
    );
  
//--------  ROW 14 --------//
    ROW_PE row14(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[23:16]),
        .up_in(down_out[12]),
        .down_out(down_out[13]),
        .sum(sum[13])
    ); 
    
//--------  ROW 15 --------//
    ROW_PE row15(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[15:8]),
        .up_in(down_out[13]),
        .down_out(down_out[14]),
        .sum(sum[14])
    ); 
    
//--------  ROW 16 --------//
    ROW_PE row16(
        .clk(clk),
        .rst(rst),
        .zero(done),
        .left_in(data_in[7:0]),
        .up_in(down_out[14]),
        .down_out(down_out[15]),
        .sum(sum[15])
    );    
    
endmodule
