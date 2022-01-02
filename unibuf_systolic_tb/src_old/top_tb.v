`timescale 1ns/10ps
`include "define.v"
`include "matrix_define.v"

module top_tb;


    reg clk;
    reg rst;
    reg instr_valid;
    reg [104:0] instr;

    reg [`WORD_ADDR_BITS-1:0]   data_total;
    wire    ack;
    wire    done;
    integer err_A, err_B, err, i, j;


    reg [`WORD_SIZE-1:0] GOLDEN_A [0:`WORD_CNT-1];
    reg [`WORD_SIZE-1:0] GOLDEN_B [0:`WORD_CNT-1];
    reg [104:0]           INSTR    [0:9];

    always #(`CYCLE/2) clk = ~clk;

    TOP top_i(
        .clk            (clk            ),
        .rst            (rst            ),
        .instr_valid    (instr_valid    ),
        .instr          (instr          ),
        .data_total     (data_total     ),
        .ack            (ack            ),
        .done           (done           )
    );

    initial begin
        for(i=0;i<10;i=i+1) begin
            INSTR[i] = 0;
        end

        clk = 1'b1; rst = 1'b0; instr_valid = 1'b0; instr = 0;
        err = 0; data_total = 0;
        #(`CYCLE*10) rst = 1'b1; data_total = `O_MAX; 

        $readmemb("build/A_input.bin", top_i.GBUFF_A.gbuff);
        $readmemb("build/B_input.bin", top_i.GBUFF_B.gbuff);
        $readmemb("build/A_golden.bin", GOLDEN_A);
        $readmemb("build/B_golden.bin", GOLDEN_B);
        $readmemb("build/instruction.bin", INSTR);

        $display("Data load finished\n");
        //* start to config
        #(`CYCLE * 5)
        @(posedge clk) instr_valid = 1'b1; instr = INSTR[0];
        @(posedge ack) instr_valid = 1'b0; instr = 0;
        #(`CYCLE * 5);
        @(posedge clk) instr_valid = 1'b1; instr = INSTR[1];
        @(posedge ack) instr_valid = 1'b0; instr = 0;

        wait(done == 1);
        $display("\nSimulation Done\n");
        err = 0;

        for(i=0;i<`O_MAX; i=i+1) begin
            $display("%2d ================================================= %2d", i, i);
            for(j=0;j<16;j=j+1) begin
                if(GOLDEN_A[i][(127-j*8) -:8] !== top_i.GBUFF_O_uni.gbuff[i][(127-j*8) -:8]) begin
                    $write("GBUFF_O_uni[%2d][%3d:%3d] = %2h, expect = %2h ",
                    i, 127-j*8, 127-(j+1)*8+1, top_i.GBUFF_O_uni.gbuff[i][(127-j*8) -:8], GOLDEN_A[i][(127-j*8) -:8]);
                    err = err +1;
                end else begin
                    $write("GBUFF_O_uni[%2d][%3d:%3d] = %2h, pass!       ",  
                    i,127-j*8, 127-(j+1)*8+1, top_i.GBUFF_O_uni.gbuff[i][(127-j*8) -:8]);
                end
                //* B
                if(GOLDEN_B[i][(127-j*8) -:8] !== top_i.GBUFF_O_wei.gbuff[i][(127-j*8) -:8]) begin
                    $display("GBUFF_O_wei[%2d][%3d:%3d] = %2h, expect = %2h ",
                    i, 127-j*8, 127-(j+1)*8+1, top_i.GBUFF_O_wei.gbuff[i][(127-j*8) -:8], GOLDEN_B[i][(127-j*8) -:8]);
                    err = err +1;
                end else begin
                    $display("GBUFF_O_wei[%2d][%3d:%3d] = %2h, pass!       ", 
                    i, 127-j*8, 127-(j+1)*8+1, top_i.GBUFF_O_wei.gbuff[i][(127-j*8) -:8]);
                end
            end
        end
        check_err(err);
        $finish;
    end //* end of initial


//----------------------------------------------------------------------------//
// Task Declarations                                                          //
//----------------------------------------------------------------------------//
  task check_err;
    input integer err;

    if( err == 0 )
    begin
      $display("\n");
      $display("                                             / \\  //\\                      ");
      $display("                              |\\___/|      /   \\//  \\\\                   ");
      $display("                             /0  0  \\__  /    //  | \\ \\                   ");
      $display("                            /     /  \\/_/    //   |  \\  \\                 ");
      $display("                            @_^_@'/   \\/_   //    |   \\   \\               ");
      $display("                            //_^_/     \\/_ //     |    \\    \\             ");
      $display("                         ( //) |        \\///      |     \\     \\           ");
      $display("                        ( / /) _|_ /   )  //       |      \\     _\\         ");
      $display("                      ( // /) '/,_ _ _/  ( ; -.    |    _ _\\.-~        .-~~~^-.                      ");
      $display(" ********************(( / / )) ,-{        _      `-.|.-~-.            .~         `.                   ");
      $display(" **                   (( // / ))  '/\\      /                 ~-. _ .-~      .-~^-.  \                ");
      $display(" **  Congratulations!  (( /// ))      `.   {            }                    /      \  \              ");
      $display(" **  Simulation Passed!  (( / ))     .----~-.\\        \\-'                .~         \  `. \^-.      ");
      $display(" **                      **           ///.----..>        \\             _ -~             `.  ^-`  ^-_ ");
      $display(" **************************             ///-._ _ _ _ _ _ _}^ - - - -- ~                     ~-- ,.-~  ");
      $display("\n");
    end
    else
    begin
      $display("\n");
      $display(" **************************    __ __   ");
      $display(" **                      **   /--\\/ \\ ");
      $display(" **  Awwwww              **  |   /   | ");
      $display(" **  Simulation Failed!  **  |-    --| ");
      $display(" **                      **   \\__-*_/ ");
      $display(" **************************            ");
      $display(" Total %4d errors\n", err);
    end
  endtask



endmodule

