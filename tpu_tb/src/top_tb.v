`timescale 1ns/10ps
`include "define.v"
`include "matrix_define.v"

module top_tb;


    reg clk;
    reg rst;
    reg start;
    wire done;
    reg [7:0] row_a, col_b, k;
    integer err, i, row_offset, j;


    reg [`WORD_SIZE-1:0] GOLDEN [0:`WORD_CNT-1];
    always #(`CYCLE/2) clk = ~clk;

    TOP top_i(
        .clk(clk),
        .rst(rst),
        .start(start),
        .m(row_a),
        .k(k),
        .n(col_b),
        .done(done)
    );


    initial begin
        clk = 0; rst = 0; start = 0;
        #(`CYCLE * 5) rst = 1; start = 1; top_i.tpu_out_valid = 1'b0;
        row_a = `MATRIX_A_ROW; col_b = `MATRIX_B_COL; k = `MATRIX_A_COL;
        $readmemb("build/matrix_a.bin", top_i.GBUFF_A.gbuff);
        $readmemb("build/matrix_b.bin", top_i.GBUFF_B.gbuff);
        $readmemb("build/golden.bin", GOLDEN);

        $display("Matrix a");
        for(i=0;i<9;i=i+1) begin
            $display("GBUFF_A[%2d] = %2h_%2h_%2h_%2h_%2h_%2h_%2h_%2h_%2h_%2h_%2h_%2h_%2h_%2h_%2h_%2h\n",
            i,
            top_i.GBUFF_A.gbuff[i][127:120],
            top_i.GBUFF_A.gbuff[i][119:112],
            top_i.GBUFF_A.gbuff[i][111:104],
            top_i.GBUFF_A.gbuff[i][103:96],
            top_i.GBUFF_A.gbuff[i][95:88],
            top_i.GBUFF_A.gbuff[i][87:80],
            top_i.GBUFF_A.gbuff[i][79:72],
            top_i.GBUFF_A.gbuff[i][71:64],
            top_i.GBUFF_A.gbuff[i][63:56],
            top_i.GBUFF_A.gbuff[i][55:48],
            top_i.GBUFF_A.gbuff[i][47:40],
            top_i.GBUFF_A.gbuff[i][39:32],
            top_i.GBUFF_A.gbuff[i][31:24],
            top_i.GBUFF_A.gbuff[i][23:16],
            top_i.GBUFF_A.gbuff[i][15:8],
            top_i.GBUFF_A.gbuff[i][7:0]);
        end



        #(`CYCLE * 30) top_i.tpu_out_valid = 1'b1; top_i.tpu_done = 1'b0;
        #(`CYCLE * 30) top_i.tpu_out_valid = 1'b0; top_i.tpu_done = 1'b1;





        wait(done == 1);
        $display("\nSimulation Done.\n");
        
        
        err = 0;
        for(i=0;i<`MATRIX_A_ROW; i=i+1) begin
            //* 127:120
            if(GOLDEN[i][127:120] !== top_i.GBUFF_OUT.gbuff[i][127:120]) begin
                $display("GBUFF_OUT[%2d][127:120] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][127:120], GOLDEN[i][127:120]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][127:120] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][127:120]);
            end
            //* 119:112
            if(GOLDEN[i][119:112] !== top_i.GBUFF_OUT.gbuff[i][119:112]) begin
                $display("GBUFF_OUT[%2d][119:112] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][119:112], GOLDEN[i][119:112]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][119:112] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][119:112]);
            end
            //* 111:104
            if(GOLDEN[i][111:104] !== top_i.GBUFF_OUT.gbuff[i][111:104]) begin
                $display("GBUFF_OUT[%2d][111:104] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][111:104], GOLDEN[i][111:104]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][111:104] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][111:104]);
            end
            //* 103:96
            if(GOLDEN[i][103:96] !== top_i.GBUFF_OUT.gbuff[i][103:96]) begin
                $display("GBUFF_OUT[%2d][103:96] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][103:96], GOLDEN[i][103:96]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][103:96] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][103:96]);
            end
            //* 95:88
            if(GOLDEN[i][95:88] !== top_i.GBUFF_OUT.gbuff[i][95:88]) begin
                $display("GBUFF_OUT[%2d][95:88] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][95:88], GOLDEN[i][95:88]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][95:88] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][95:88]);
            end
            //* 87:80
            if(GOLDEN[i][87:80] !== top_i.GBUFF_OUT.gbuff[i][87:80]) begin
                $display("GBUFF_OUT[%2d][87:80] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][87:80], GOLDEN[i][87:80]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][87:80] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][87:80]);
            end
            //* 79:72
            if(GOLDEN[i][79:72] !== top_i.GBUFF_OUT.gbuff[i][79:72]) begin
                $display("GBUFF_OUT[%2d][79:72] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][79:72], GOLDEN[i][79:72]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][79:72] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][79:72]);
            end
            //* 71:64
            if(GOLDEN[i][71:64] !== top_i.GBUFF_OUT.gbuff[i][71:64]) begin
                $display("GBUFF_OUT[%2d][71:64] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][71:64], GOLDEN[i][71:64]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][71:64] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][71:64]);
            end
            //* 63:56
            if(GOLDEN[i][63:56] !== top_i.GBUFF_OUT.gbuff[i][63:56]) begin
                $display("GBUFF_OUT[%2d][63:56] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][63:56], GOLDEN[i][63:56]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][63:56] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][63:56]);
            end
            //* 55:48
            if(GOLDEN[i][55:48] !== top_i.GBUFF_OUT.gbuff[i][55:48]) begin
                $display("GBUFF_OUT[%2d][55:48] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][55:48], GOLDEN[i][55:48]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][55:48] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][55:48]);
            end
            //* 47:40
            if(GOLDEN[i][47:40] !== top_i.GBUFF_OUT.gbuff[i][47:40]) begin
                $display("GBUFF_OUT[%2d][47:40] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][47:40], GOLDEN[i][47:40]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][47:40] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][47:40]);
            end
            //* 39:32
            if(GOLDEN[i][39:32] !== top_i.GBUFF_OUT.gbuff[i][39:32]) begin
                $display("GBUFF_OUT[%2d][39:32] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][39:32], GOLDEN[i][39:32]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][39:32] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][39:32]);
            end
            //* 31:24
            if(GOLDEN[i][31:24] !== top_i.GBUFF_OUT.gbuff[i][31:24]) begin
                $display("GBUFF_OUT[%2d][31:24] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][31:24], GOLDEN[i][31:24]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][31:24] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][31:24]);
            end
            //* 23:16
            if(GOLDEN[i][23:16] !== top_i.GBUFF_OUT.gbuff[i][23:16]) begin
                $display("GBUFF_OUT[%2d][23:16] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][23:16], GOLDEN[i][23:16]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][23:16] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][23:16]);
            end
            //* 15:8
            if(GOLDEN[i][15:8] !== top_i.GBUFF_OUT.gbuff[i][15:8]) begin
                $display("GBUFF_OUT[%2d][15:8] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][15:8], GOLDEN[i][15:8]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][15:8] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][15:8]);
            end
            //* 7:0
            if(GOLDEN[i][7:0] !== top_i.GBUFF_OUT.gbuff[i][7:0]) begin
                $display("GBUFF_OUT[%2d][7:0] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][7:0], GOLDEN[i][7:0]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][7:0] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][7:0]);
            end
        end

        check_err(err);
        $finish;
    end

//----------------------------------------------------------------------------//
// Maximum Simulation                                                         //
//----------------------------------------------------------------------------//

    initial begin
        #(`CYCLE*`MAX) err = 0;
        for(i=0;i<`MATRIX_A_ROW; i=i+1) begin
            //* 127:120
            if(GOLDEN[i][127:120] !== top_i.GBUFF_OUT.gbuff[i][127:120]) begin
                $display("GBUFF_OUT[%2d][127:120] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][127:120], GOLDEN[i][127:120]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][127:120] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][127:120]);
            end
            //* 119:112
            if(GOLDEN[i][119:112] !== top_i.GBUFF_OUT.gbuff[i][119:112]) begin
                $display("GBUFF_OUT[%2d][119:112] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][119:112], GOLDEN[i][119:112]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][119:112] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][119:112]);
            end
            //* 111:104
            if(GOLDEN[i][111:104] !== top_i.GBUFF_OUT.gbuff[i][111:104]) begin
                $display("GBUFF_OUT[%2d][111:104] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][111:104], GOLDEN[i][111:104]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][111:104] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][111:104]);
            end
            //* 103:96
            if(GOLDEN[i][103:96] !== top_i.GBUFF_OUT.gbuff[i][103:96]) begin
                $display("GBUFF_OUT[%2d][103:96] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][103:96], GOLDEN[i][103:96]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][103:96] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][103:96]);
            end
            //* 95:88
            if(GOLDEN[i][95:88] !== top_i.GBUFF_OUT.gbuff[i][95:88]) begin
                $display("GBUFF_OUT[%2d][95:88] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][95:88], GOLDEN[i][95:88]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][95:88] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][95:88]);
            end
            //* 87:80
            if(GOLDEN[i][87:80] !== top_i.GBUFF_OUT.gbuff[i][87:80]) begin
                $display("GBUFF_OUT[%2d][87:80] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][87:80], GOLDEN[i][87:80]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][87:80] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][87:80]);
            end
            //* 79:72
            if(GOLDEN[i][79:72] !== top_i.GBUFF_OUT.gbuff[i][79:72]) begin
                $display("GBUFF_OUT[%2d][79:72] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][79:72], GOLDEN[i][79:72]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][79:72] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][79:72]);
            end
            //* 71:64
            if(GOLDEN[i][71:64] !== top_i.GBUFF_OUT.gbuff[i][71:64]) begin
                $display("GBUFF_OUT[%2d][71:64] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][71:64], GOLDEN[i][71:64]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][71:64] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][71:64]);
            end
            //* 63:56
            if(GOLDEN[i][63:56] !== top_i.GBUFF_OUT.gbuff[i][63:56]) begin
                $display("GBUFF_OUT[%2d][63:56] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][63:56], GOLDEN[i][63:56]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][63:56] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][63:56]);
            end
            //* 55:48
            if(GOLDEN[i][55:48] !== top_i.GBUFF_OUT.gbuff[i][55:48]) begin
                $display("GBUFF_OUT[%2d][55:48] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][55:48], GOLDEN[i][55:48]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][55:48] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][55:48]);
            end
            //* 47:40
            if(GOLDEN[i][47:40] !== top_i.GBUFF_OUT.gbuff[i][47:40]) begin
                $display("GBUFF_OUT[%2d][47:40] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][47:40], GOLDEN[i][47:40]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][47:40] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][47:40]);
            end
            //* 39:32
            if(GOLDEN[i][39:32] !== top_i.GBUFF_OUT.gbuff[i][39:32]) begin
                $display("GBUFF_OUT[%2d][39:32] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][39:32], GOLDEN[i][39:32]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][39:32] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][39:32]);
            end
            //* 31:24
            if(GOLDEN[i][31:24] !== top_i.GBUFF_OUT.gbuff[i][31:24]) begin
                $display("GBUFF_OUT[%2d][31:24] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][31:24], GOLDEN[i][31:24]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][31:24] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][31:24]);
            end
            //* 23:16
            if(GOLDEN[i][23:16] !== top_i.GBUFF_OUT.gbuff[i][23:16]) begin
                $display("GBUFF_OUT[%2d][23:16] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][23:16], GOLDEN[i][23:16]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][23:16] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][23:16]);
            end
            //* 15:8
            if(GOLDEN[i][15:8] !== top_i.GBUFF_OUT.gbuff[i][15:8]) begin
                $display("GBUFF_OUT[%2d][15:8] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][15:8], GOLDEN[i][15:8]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][15:8] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][15:8]);
            end
            //* 7:0
            if(GOLDEN[i][7:0] !== top_i.GBUFF_OUT.gbuff[i][7:0]) begin
                $display("GBUFF_OUT[%2d][7:0] = %2h, expect = %2h",
                i, top_i.GBUFF_OUT.gbuff[i][7:0], GOLDEN[i][7:0]);
                err = err +1;
            end else begin
                $display("GBUFF_OUT[%2d][7:0] = %2h, pass!", 
                i, top_i.GBUFF_OUT.gbuff[i][7:0]);
            end
        end

        check_err(err);
        $finish;
    end



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

