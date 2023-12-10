//testbench
`timescale 1ns /10ps
`define cycle 10
`define terminateCycle 100000000

`define IN_FILE "./in_2.txt"
`define H_FILE "./H_2.txt"
`define L_FILE "./L_2.txt"

`define DATA_SIZE 63
`define DATA_LEN 8

module testfixture;
    reg clk, reset;
    reg [7:0] in_data;
    wire [7:0] d1_out, d2_out, d3_out, d4_out;
    wire [7:0] ld1_out, ld2_out, ld3_out, ld4_out, ld5_out;
    wire [7:0] L_out;
    wire [7:0] H_out;
    wire [2:0] state;
    wire [7:0] mux_a, mux_b, mux_c, mux_d, mux_e;
    integer datCnt, L_err, H_err;

   // integer err, pass;
    TOP u1(clk, reset, in_data, L_out, H_out);


    reg [`DATA_LEN:0] dataMem [0:`DATA_SIZE - 1];
    reg [`DATA_LEN:0] L [0:`DATA_SIZE - 1];
    reg [`DATA_LEN:0] H [0:`DATA_SIZE - 1];

    initial begin
        $timeformat(-9, 1, " ns", 9);
        $readmemb(`IN_FILE, dataMem);
        $readmemb(`H_FILE, H);
        $readmemb(`L_FILE, L);
    end

    initial begin
        clk <= 0;
        reset <= 1;
        L_err <= 0;
        H_err <= 0;
        # `cycle
        reset <= 0;
    end

    always #(`cycle / 2) clk = ~clk;
    initial begin
        $display("Start Simulation");
        $display("         \\      ");
        $display(" \\      (o>     ");
        $display(" (o>     //\     ");
        $display("_(()_____V_/_____");
        $display(" ||      ||      ");
        $display("         ||      ");
        $display("-----------------");
    end


    initial begin
        datCnt = 0;
        # (`cycle);
        while(datCnt < `DATA_SIZE) begin
            in_data = dataMem[datCnt];
            if (H_out !== H[datCnt] && datCnt != 27 && datCnt != 43 && datCnt != 59) begin
                H_err = H_err + 1;
                $display("No.%d -> Correct H answer is %d",datCnt , H[datCnt]);
                $display("No.%d -> Your answer is %d",datCnt , H_out);
            end
            if (L_out !== L[datCnt] && datCnt != 28 && datCnt != 44 && datCnt != 60) begin
                L_err = L_err + 1;
                $display("No.%d -> Correct L answer is %d",datCnt , L[datCnt]);
                $display("No.%d -> Your answer is %d",datCnt , L_out);
            end
            # (`cycle); 
            datCnt = datCnt + 1;
        end
        # `cycle
        $display("Simulation is done");
        if((L_err + H_err) == 0)begin
            $display("\n");
            $display("      ************************                   ");
            $display("      *                      *           \\      ");
            $display("      *     Successful !!    *   \\      (o>     ");
            $display("      *                      *   (o>     //\     ");
            $display("      *  Simulation PASS!!   *  _(()_____V_/_____");
            $display("      *                      *   ||      ||      ");
            $display("      ************************           ||      ");
            $display("\n");
        end 
        else begin
            $display("\n");
            $display("     ************************                   ");
            $display("     *                      *           \\      ");
            $display("     *  OOPS!!              *   \\      (o>     ");
            $display("     *                      *   (o>     //\     ");
            $display("     *  Simulation Failed!! *  _(()_____V_/_____");
            $display("     *                      *   ||      ||      ");
            $display("     ************************           ||      ");
            $display("     Totally has %d errors                      ", L_err + H_err);
            $display("\n");
        end
        $finish;
    end

endmodule
