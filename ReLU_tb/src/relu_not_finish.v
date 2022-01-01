`ifndef _relu_
`define _relu_


`default_nettype none

module relu
  #(parameter
    NUM_WIDTH = 16)
   (input  wire                 clk,
    input  wire                 bypass,

    input  wire [NUM_WIDTH-1:0] up_data,
    output reg  [NUM_WIDTH-1:0] dn_data
);



    function greater_than_zero;
        input [NUM_WIDTH-1:0] arg;

        begin
            greater_than_zero = ~arg[NUM_WIDTH-1];
        end
    endfunction


    reg  [NUM_WIDTH-1:0]    up_data_1p;



    always @(posedge clk) begin
        up_data_1p <= 'b0;

        if (bypass || greater_than_zero(up_data)) begin
            up_data_1p <= up_data;
        end
    end


    always @(posedge clk)
        dn_data <= up_data_1p;