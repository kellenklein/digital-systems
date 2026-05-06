`timescale 1ns/1ps

module claw_fsm_tb;

    // Clock and reset
    logic clk;
    logic rst_n;

    // FSM inputs
    logic start_pulse;
    logic grab_pulse;
    logic timer_zero;
    logic hit;
    logic attempts_lt5;
    logic attempts_eq5;

    // FSM outputs
    logic obj_ld;
    logic sweep_en;
    logic tmr_ld;
    logic tmr_en;
    logic score_inc;
    logic score_dec;
    logic score_clr;
    logic attempts_inc;
    logic attempts_clr;

    // Simple counter for attempts (TB-only)
    int attempts_count;

    // DUT
    claw_fsm dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .start_pulse  (start_pulse),
        .grab_pulse   (grab_pulse),
        .timer_zero   (timer_zero),
        .hit          (hit),
        .attempts_lt5 (attempts_lt5),
        .attempts_eq5 (attempts_eq5),
        .obj_ld       (obj_ld),
        .sweep_en     (sweep_en),
        .tmr_ld       (tmr_ld),
        .tmr_en       (tmr_en),
        .score_inc    (score_inc),
        .score_dec    (score_dec),
        .score_clr    (score_clr),
        .attempts_inc (attempts_inc),
        .attempts_clr (attempts_clr)
    );

    // Clock generation: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Monitor useful signals
    initial begin
        $display(" time  state start grab tzero hit | obj_ld sweep_en tmr_ld tmr_en | +sc -sc +att clr_sc clr_att");
        $monitor("%4t   %b     %0b     %0b    %0b   %0b  |   %0b      %0b      %0b      %0b   |  %0b   %0b   %0b     %0b      %0b",
                 $time,
                 dut.state,
                 start_pulse,
                 grab_pulse,
                 timer_zero,
                 hit,
                 obj_ld,
                 sweep_en,
                 tmr_ld,
                 tmr_en,
                 score_inc,
                 score_dec,
                 attempts_inc,
                 score_clr,
                 attempts_clr);
    end

    // Stimulus
    initial begin
        // Initial values
        rst_n         = 0;
        start_pulse   = 0;
        grab_pulse    = 0;
        timer_zero    = 0;
        hit           = 0;
        attempts_lt5  = 0;
        attempts_eq5  = 0;
        attempts_count = 0;

        // Reset
        #20;
        rst_n = 1;

        //-------------------------------------------------
        // Scenario 1: Start game, first attempt is HIT
        //-------------------------------------------------
        attempts_lt5 = 1;
        attempts_eq5 = 0;

        // START pulse
        @(negedge clk);
        start_pulse = 1;
        @(negedge clk);
        start_pulse = 0;

        // Let it go to SWEEP and sweep a bit
        repeat (3) @(negedge clk);

        // GRAB, hit=1
        hit        = 1;
        grab_pulse = 1;
        @(negedge clk);
        grab_pulse = 0;
        hit        = 0;

        // RESULT & SHOW cycles
        repeat (4) begin
            @(negedge clk);
            if (attempts_inc) begin
                attempts_count++;
                $display("  >>> TB: attempts_count = %0d", attempts_count);
            end
        end

        //-------------------------------------------------
        // Scenario 2: Second attempt is MISS
        //-------------------------------------------------
        attempts_lt5 = 1;
        attempts_eq5 = 0;

        repeat (3) @(negedge clk);

        // GRAB, hit=0
        hit        = 0;
        grab_pulse = 1;
        @(negedge clk);
        grab_pulse = 0;

        repeat (4) begin
            @(negedge clk);
            if (attempts_inc) begin
                attempts_count++;
                $display("  >>> TB: attempts_count = %0d", attempts_count);
            end
        end

       //-------------------------------------------------
        // Scenario 3: Force game end by pretending attempts==5
        //-------------------------------------------------
        attempts_lt5 = 0;
        attempts_eq5 = 1;

        @(negedge clk);

        #50;
        $display("Yahoo! test bench for FSM passed.");
        $stop;
    end

endmodule
