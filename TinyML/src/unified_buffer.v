module unified_buffer(
    input clk,
    input reset,

    //* Control Unit Interface
    input           ctrl_valid,
    input   [31:0]  ctrl_init_addr,
    input   [9:0]   ctrl_col,
    input   [9:0]   ctrl_row,
    input   [31:0]  ctrl_out_addr,
    output          ready,
    output          busy,


    //* DRAM interface
    output        ram_ena,
    output        ram_wea,
    output [31:0] ram_addr,
    output [31:0] ram_data_out,
    input  [31:0] ram_data_in,

    //* Systolic Data Setup Unit
    output        sdsu_valid,
    output [31:0] sdsu_data_out,
    output        sdsu_type,
    input         sdsu_ready,

    //* Write back data
    input  [31:0] wb_addr,
    input  [31:0] wb_data_in,
    input         wb_en,
    output        wb_ready,
    
);












endmodule