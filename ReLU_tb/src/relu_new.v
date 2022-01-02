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
	
	always @(posedge clk or posedge rst) begin
    if (rst)
        begin
            last_relu <= {OUTPUT_DATA_WIDTH{1'b0}};
        end
    else
        begin
            last_relu <= (last[OUTPUT_DATA_WIDTH-1] == 1'b1) ? ({OUTPUT_DATA_WIDTH{1'b0}}) : (last); 
        end
    end
	always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            input_bram_rd_en <= 1'b0;
            weight_bram_rd_en <= 1'b0;
        end
        else
        begin
            input_bram_rd_en <='b1; 
            weight_bram_rd_en <= 1'b1;
        end
    end
	
	
	always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            DI_valid <= 1'b1;
        end
        else if(start_pulse)
        begin
            DI_valid <= 1'b0;
        end
        else if(done)
        begin
            DI_valid <= 1'b1;
        end
        else
        begin
            DI_valid <= DI_valid;
        end
    end
    assign DI_valid = DI_valid;

    always @(posedge clk) begin
        DI <= 'b0;

        if (bypass || greater_than_zero(DO)) begin
            DI <= DO;
        end
    end


    always @(posedge clk)
        DO <= DI;


