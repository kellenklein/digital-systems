`timescale 1ns/1ps

module sweep_ctrl_tb;

    localparam int N_LEDS    = 8;
    localparam int WIN_WIDTH = 1;

    // DUT signals
    logic               rst_n;
    logic               sweep_clk;
    logic               sweep_en;
    logic [N_LEDS-1:0]  led_window;

    // To check that holding works
    logic [N_LEDS-1:0]  prev_window;

    // DUT instance
    sweep_ctrl #(
        .N_LEDS   (N_LEDS),
        .WIN_WIDTH(WIN_WIDTH)
    ) dut (
        .rst_n     (rst_n),
        .sweep_clk (sweep_clk),
        .sweep_en  (sweep_en),
        .led_window(led_window)
    );

    // Clock generation: 20 ns period
    initial sweep_clk = 1'b0;
    always #10 sweep_clk = ~sweep_clk;

    // Output monitor
    initial begin
        $display(" time  rst_n sweep_en  led_window");
        $monitor("%4t    %0b      %0b      %b",
                 $time, rst_n, sweep_en, led_window);
    end

    //-----------------------------------------------------------
    // MAIN STIMULUS
    //-----------------------------------------------------------
    initial begin
        rst_n    = 1'b0;
        sweep_en = 1'b0;

        // Release reset
        #25 rst_n = 1'b1;

        //-------------------------
        // 1) DISABLE → HOLD TEST (right after reset)
        //-------------------------
        prev_window = led_window;
        repeat (5) @(posedge sweep_clk);
        if (led_window !== prev_window)
            $fatal(1, "ERROR: Window moved while sweep_en = 0 (HOLD test after reset).");
        else
            $display("PASS: sweep_en=0 correctly holds window after reset.");

        //-------------------------
        // 2) ENABLE → MOVE TEST
        //-------------------------
        sweep_en = 1'b1;
        @(posedge sweep_clk);
        prev_window = led_window;
        @(posedge sweep_clk);
        if (led_window === prev_window)
            $fatal(1, "ERROR: Window did not move when sweep_en = 1.");
        else
            $display("PASS: sweep_en=1 correctly moves window.");

        //-------------------------
        // 3) MID-MOTION DISABLE → HOLD TEST
        //-------------------------
        // Let it move a bit
        repeat (3) @(posedge sweep_clk);

        // Now disable sweep in the middle of motion
        sweep_en = 1'b0;

        // Let the DUT see sweep_en=0 on a clock edge, then capture
        @(posedge sweep_clk);
        prev_window = led_window;

        // Now check that it holds for several cycles
        repeat (4) @(posedge sweep_clk);
        if (led_window !== prev_window)
            $fatal(1, "ERROR: Window moved during sweep_en=0 (mid-motion disable).");
        else
            $display("PASS: mid-motion disable correctly freezes window.");

        $display("\nSweep_ctrl test completed successfully.\n");
        $finish;
    end

endmodule
