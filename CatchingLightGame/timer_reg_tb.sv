`timescale 1ns/1ps

module timer_reg_tb;

    // Use a small timer for easy simulation
    localparam int WIDTH_TB       = 4;
    localparam     [WIDTH_TB-1:0] ROUND_MAX_TB = 4'd5;

    // DUT signals
    logic                  clk;
    logic                  rst_n;
    logic                  tick;
    logic                  tmr_ld;
    logic                  tmr_en;
    logic [WIDTH_TB-1:0]   tmr_val;
    logic                  timer_zero;

    integer step;  // loop variable

    // DUT instance
    timer_reg #(
        .WIDTH    (WIDTH_TB),
        .ROUND_MAX(ROUND_MAX_TB)
    ) dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .tick       (tick),
        .tmr_ld     (tmr_ld),
        .tmr_en     (tmr_en),
        .tmr_val    (tmr_val),
        .timer_zero (timer_zero)
    );

    // Clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("=== timer_reg Testbench ===");

        // ------------------------------------------------------------
        // Reset
        // ------------------------------------------------------------
        rst_n   = 1'b0;
        tick    = 1'b0;
        tmr_ld  = 1'b0;
        tmr_en  = 1'b0;

        repeat (2) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);

        $display("[%0t] After reset: tmr_val = %0d, timer_zero = %0b",
                 $time, tmr_val, timer_zero);

        if (tmr_val !== {WIDTH_TB{1'b0}})
            $fatal(1, "ERROR: tmr_val should be 0 after reset!");
        if (!timer_zero)
            $fatal(1, "ERROR: timer_zero should be 1 when tmr_val=0 after reset!");

        // ------------------------------------------------------------
        // Load timer (tmr_ld)
        // ------------------------------------------------------------
        tmr_ld = 1'b1;
        @(posedge clk);
        tmr_ld = 1'b0;
        @(posedge clk);

        $display("[%0t] After load: tmr_val = %0d (expected %0d), timer_zero = %0b",
                 $time, tmr_val, ROUND_MAX_TB, timer_zero);

        if (tmr_val !== ROUND_MAX_TB)
            $fatal(1, "ERROR: tmr_val did not load ROUND_MAX correctly!");
        if (timer_zero)
            $fatal(1, "ERROR: timer_zero should be 0 when tmr_val>0!");

        // ------------------------------------------------------------
        // Countdown with tmr_en & tick until zero
        // ------------------------------------------------------------
        tmr_en = 1'b1;

        for (step = ROUND_MAX_TB-1; step >= 0; step = step - 1) begin
            // Generate a tick for this cycle
            tick = 1'b1;
            @(posedge clk);
            tick = 1'b0;
            @(posedge clk);

            $display("[%0t] After tick: tmr_val = %0d (expected %0d), timer_zero = %0b",
                     $time, tmr_val, step[WIDTH_TB-1:0], timer_zero);

            if (tmr_val !== step[WIDTH_TB-1:0])
                $fatal(1, "ERROR: timer did not decrement correctly!");

            if (step == 0 && !timer_zero)
                $fatal(1, "ERROR: timer_zero should be 1 when tmr_val=0!");
            if (step > 0 && timer_zero)
                $fatal(1, "ERROR: timer_zero should be 0 when tmr_val>0!");
        end

        // ------------------------------------------------------------
        // Extra tick at zero → must stay at 0
        // ------------------------------------------------------------
        tick = 1'b1;
        @(posedge clk);
        tick = 1'b0;
        @(posedge clk);

        $display("[%0t] After extra tick at zero: tmr_val = %0d (expected 0), timer_zero = %0b",
                 $time, tmr_val, timer_zero);

        if (tmr_val !== {WIDTH_TB{1'b0}})
            $fatal(1, "ERROR: tmr_val should stay at 0 and not go negative!");
        if (!timer_zero)
            $fatal(1, "ERROR: timer_zero should remain 1 when tmr_val=0!");

        // ------------------------------------------------------------
        // Done
        // ------------------------------------------------------------
        $display("Yahoo! timer_reg testbench PASSED!");
        $stop;
    end

endmodule
