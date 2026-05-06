`timescale 1ns/1ps

module score_reg_tb;

    localparam int WIDTH_TB = 4;

    // DUT signals
    logic                  clk;
    logic                  rst_n;
    logic                  score_inc;
    logic                  score_dec;
    logic                  score_clr;
    logic [WIDTH_TB-1:0]   score;

    // DUT instance
    score_reg #(
        .WIDTH(WIDTH_TB)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .score_inc (score_inc),
        .score_dec (score_dec),
        .score_clr (score_clr),
        .score     (score)
    );

    // Clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("=== score_reg Testbench ===");

        //--------------------------------------------------
        // Reset
        //--------------------------------------------------
        rst_n      = 0;
        score_inc  = 0;
        score_dec  = 0;
        score_clr  = 0;

        @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        $display("[%0t] After reset: score=%0d", $time, score);
        if (score !== 4'd0)
            $fatal(1, "ERROR: score must be 0 after async reset!");

        //--------------------------------------------------
        // score_clr → load 5
        //--------------------------------------------------
        score_clr = 1;
        @(posedge clk);
        score_clr = 0;
        @(posedge clk);

        $display("[%0t] After score_clr: score=%0d (expected 5)", $time, score);
        if (score !== 4'd5)
            $fatal(1, "ERROR: score_clr failed: expected 5, got %0d", score);  

        //--------------------------------------------------
        // score_inc: 5 → 6
        //--------------------------------------------------
        score_inc = 1;
        @(posedge clk);
        score_inc = 0;
        @(posedge clk);

        $display("[%0t] After score_inc #1: score=%0d (expected 6)", $time, score);
        if (score !== 4'd6)
            $fatal(1, "ERROR: score_inc failed: expected 6, got %0d", score); 

        //--------------------------------------------------
        // score_inc: 6 → 7
        //--------------------------------------------------
        score_inc = 1;
        @(posedge clk);
        score_inc = 0;
        @(posedge clk);

        $display("[%0t] After score_inc #2: score=%0d (expected 7)", $time, score);
        if (score !== 4'd7)
            $fatal(1, "ERROR: score_inc failed: expected 7, got %0d", score);

        //--------------------------------------------------
        // score_dec: 7 → 6
        //--------------------------------------------------
        score_dec = 1;
        @(posedge clk);
        score_dec = 0;
        @(posedge clk);

        $display("[%0t] After score_dec: score=%0d (expected 6)", $time, score);
        if (score !== 4'd6)
            $fatal(1, "ERROR: score_dec failed: expected 6, got %0d", score);

        //--------------------------------------------------
        // HOLD behavior: no inc/dec/clear
        //--------------------------------------------------
        @(posedge clk);
        @(posedge clk);
        $display("[%0t] After hold: score=%0d (expected 6)", $time, score);
        if (score !== 4'd6)
            $fatal(1, "ERROR: HOLD failed: score changed without a command.");

        //--------------------------------------------------
        // Done
        //--------------------------------------------------
        $display("Yahoo! score_reg testbench PASSED!");
        $stop;
    end

endmodule
