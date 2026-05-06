`timescale 1ns/1ps

module attempts_reg_tb;

    logic clk;
    logic rst_n;
    logic attempts_inc;
    logic attempts_clr;
    logic [2:0] attempts;
    logic attempts_lt5;
    logic attempts_eq5;

    integer i;
    // DUT
    attempts_reg dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .attempts_inc (attempts_inc),
        .attempts_clr (attempts_clr),
        .attempts     (attempts),
        .attempts_lt5 (attempts_lt5),
        .attempts_eq5 (attempts_eq5)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("=== attempts_reg Testbench ===");

        //------------------------------------------------------------
        // Initial / reset
        //------------------------------------------------------------
        rst_n        = 0;
        attempts_inc = 0;
        attempts_clr = 0;

        repeat (2) @(posedge clk);
        rst_n = 1;  // release async reset
        @(posedge clk);

        $display("[%0t] After reset: attempts = %0d", $time, attempts);
        if (attempts !== 3'd0)
            $fatal(1, "ERROR: attempts should be 0 after reset!");

        //------------------------------------------------------------
        // INC x5 → should count 0 → 1 → 2 → 3 → 4 → 5
        //------------------------------------------------------------
        

        for (i = 1; i <= 5; i++) begin
            attempts_inc = 1;
            @(posedge clk);
            attempts_inc = 0;
            @(posedge clk);

            $display("[%0t] After INC #%0d: attempts = %0d (expected %0d)",
                     $time, i, attempts, i);

            if (attempts !== i[2:0])
                $fatal(1, "ERROR: attempts failed to increment to %0d!", i);

            if ((i < 5) && !attempts_lt5)
                $fatal(1, "ERROR: attempts_lt5 should be 1 for attempts=%0d!", i);

            if ((i == 5) && !attempts_eq5)
                $fatal(1, "ERROR: attempts_eq5 should be 1 at attempts=5!");
        end

        //------------------------------------------------------------
        // INC again → should SATURATE and stay at 5
        //------------------------------------------------------------
        attempts_inc = 1;
        @(posedge clk);
        attempts_inc = 0;
        @(posedge clk);

        $display("[%0t] After INC beyond saturation: attempts=%0d (expected 5)",
                 $time, attempts);

        if (attempts !== 3'd5)
            $fatal(1, "ERROR: attempts should saturate at 5!");

        if (!attempts_eq5)
            $fatal(1, "ERROR: attempts_eq5 should be 1 when saturated!");

        //------------------------------------------------------------
        // CLEAR test → should go back to 0
        //------------------------------------------------------------
        attempts_clr = 1;
        @(posedge clk);
        attempts_clr = 0;
        @(posedge clk);

        $display("[%0t] After CLEAR: attempts = %0d (expected 0)",
                 $time, attempts);

        if (attempts !== 3'd0)
            $fatal(1, "ERROR: attempts did not clear to 0!");

        if (!attempts_lt5)
            $fatal(1, "ERROR: attempts_lt5 should be 1 when attempts=0!");

        //------------------------------------------------------------
        // DONE
        //------------------------------------------------------------
        $display("Yahoo! attempts_reg testbench PASSED!");
        $stop;
    end

endmodule
