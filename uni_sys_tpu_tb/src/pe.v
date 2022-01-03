`include "define.v"
module PE(
    clk,
    rst,
    zero,
    left_in,
    up_in,
    right_out,
    down_out,
    sum
);

input                          clk;
input                          rst;
input                          zero;
input      [`BYTES_SIZE-1:0]   left_in;
input      [`BYTES_SIZE-1:0]   up_in;
output reg [`BYTES_SIZE-1:0]    right_out;
output reg [`BYTES_SIZE-1:0]    down_out;
output reg [`BYTES_SIZE-1:0]    sum;

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        sum <= 8'd0;
        right_out <= 8'd0;
        down_out <= 8'd0;
    end else begin
        if(zero) begin
            sum <= 8'd0;
        end else begin
            sum <= sum + left_in * up_in;
        end
        right_out <= left_in;
        down_out <= up_in;
    end
end

endmodule

module ROW_PE(
    clk,
    rst,
    zero,
    left_in,
    up_in,
    down_out,
    sum
);

input                       clk;
input                       rst;
input                       zero;
input  [`BYTES_SIZE-1:0]    left_in;
input  [127:0]              up_in;
output [127:0]              down_out;
output [127:0]              sum;

wire   [`BYTES_SIZE-1:0]     right_out [0:15];

     PE pe1(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (left_in),
    .up_in      (up_in[127:120]),
    .right_out  (right_out[0]),
    .down_out   (down_out[127:120]),
    .sum        (sum[127:120])
    );
    
    PE pe2(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[0]),
    .up_in      (up_in[119:112]),
    .right_out  (right_out[1]),
    .down_out   (down_out[119:112]),
    .sum        (sum[119:112])
    );
    
    PE pe3(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[1]),
    .up_in      (up_in[111:104]),
    .right_out  (right_out[2]),
    .down_out   (down_out[111:104]),
    .sum        (sum[111:104])
    );
    
    PE pe4(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[2]),
    .up_in      (up_in[103:96]),
    .right_out  (right_out[3]),
    .down_out   (down_out[103:96]),
    .sum        (sum[103:96])
    );
    
    PE pe5(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[3]),
    .up_in      (up_in[95:88]),
    .right_out  (right_out[4]),
    .down_out   (down_out[95:88]),
    .sum        (sum[95:88])
    );
    
    PE pe6(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[4]),
    .up_in      (up_in[87:80]),
    .right_out  (right_out[5]),
    .down_out   (down_out[87:80]),
    .sum        (sum[87:80])
    );
    
    PE pe7(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[5]),
    .up_in      (up_in[79:72]),
    .right_out  (right_out[6]),
    .down_out   (down_out[79:72]),
    .sum        (sum[79:72])
    );
    
    PE pe8(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[6]),
    .up_in      (up_in[71:64]),
    .right_out  (right_out[7]),
    .down_out   (down_out[71:64]),
    .sum        (sum[71:64])
    );
    
    PE pe9(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[7]),
    .up_in      (up_in[63:56]),
    .right_out  (right_out[8]),
    .down_out   (down_out[63:56]),
    .sum        (sum[63:56])
    );
    
    PE pe10(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[8]),
    .up_in      (up_in[55:48]),
    .right_out  (right_out[9]),
    .down_out   (down_out[55:48]),
    .sum        (sum[55:48])
    );
    
    PE pe11(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[9]),
    .up_in      (up_in[47:40]),
    .right_out  (right_out[10]),
    .down_out   (down_out[47:40]),
    .sum        (sum[47:40])
    );
    
    PE pe12(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[10]),
    .up_in      (up_in[39:32]),
    .right_out  (right_out[11]),
    .down_out   (down_out[39:32]),
    .sum        (sum[39:32])
    );
    
    PE pe13(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[11]),
    .up_in      (up_in[31:24]),
    .right_out  (right_out[12]),
    .down_out   (down_out[31:24]),
    .sum        (sum[31:24])
    );
    
    PE pe14(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[12]),
    .up_in      (up_in[23:16]),
    .right_out  (right_out[13]),
    .down_out   (down_out[23:16]),
    .sum        (sum[23:16])
    );
    
    PE pe15(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[13]),
    .up_in      (up_in[15:8]),
    .right_out  (right_out[14]),
    .down_out   (down_out[15:8]),
    .sum        (sum[15:8])
    );
    
    PE pe16(
    .clk        (clk),
    .rst        (rst),
    .zero       (zero),
    .left_in    (right_out[14]),
    .up_in      (up_in[7:0]),
    .right_out  (right_out[15]),
    .down_out   (down_out[7:0]),
    .sum        (sum[7:0])
    );
    
endmodule