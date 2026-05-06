`timescale 1ns/1ps

module ahw3_blink_top_tb;

  // ---------------- DUT I/O ----------------
  logic        clk     = 0;
  logic        rst_n   = 0;
  logic        btn_inc = 1;     // buttons idle-high
  logic        btn_dec = 1;
  logic [7:0]  led;

  // --------------- Instantiate DUT ---------------
  ahw3_blink_top dut (
    .clk     (clk),
    .rst_n   (rst_n),
    .btn_inc (btn_inc),
    .btn_dec (btn_dec),
    .led     (led)
  ); 

  // ----------------- 100 MHz clock -----------------
  always #5 clk = ~clk;

  // ------------------- Helper funcs/tasks -------------------

  // Read speed_sel directly from DUT hierarchy
  function automatic [1:0] get_speed_sel();
    get_speed_sel = dut.u_spd.speed_sel;
  endfunction

  // Wait for one divider pulse (tick) using DUT hierarchy
  task automatic wait_tick;
    @(posedge clk);
    while (!dut.u_div.tick) @(posedge clk);
  endtask

  // Press INC; wait for synchronized one-cycle pulse; give two clocks to settle.
  task automatic press_inc_and_wait;
    begin
      btn_inc = 0;
      @(posedge clk); #1 btn_inc = 1;             // short press; release mid-cycle
      @(posedge dut.u_inc.sig_rise);              // wait on DUT hierarchical pulse
      @(posedge clk); @(posedge clk);             // allow nxt + register capture
    end
  endtask

  // Observe ONE LED cycle at the current speed: wait for a tick,
  // then for the next tick, and verify the LED changed once.
  task automatic observe_one_cycle(string tag);
    logic [7:0] led_a, led_b;
    begin
      wait_tick();  led_a = led; #1;
      wait_tick();  led_b = led; #1;

      if (led_b === led_a)
        $fatal(1, "[%s] LED did not change on tick (t=%0t)", tag, $time);

      $display("[%s] One cycle OK at t=%0t (LED: %02h -> %02h)", tag, $time, led_a, led_b);
    end
  endtask

  // ------------------ Scenario ------------------
  initial begin
    $display("Running ahw3_blink_top_tb...");

    // Reset and settle
    btn_inc = 1; btn_dec = 1; rst_n = 0;
    repeat (10) @(posedge clk);
    rst_n = 1;
    repeat (5) @(posedge clk);

    // Expect to start at slowest speed (0)
    if (get_speed_sel() !== 2'd0)
      $fatal(1, "Expected start at speed_sel=0, got %0d", get_speed_sel());

    // speed 0 (slowest): observe 1 cycle
    observe_one_cycle($sformatf("speed%0d", get_speed_sel()));

    // Step faster each time and observe one cycle at each level
    press_inc_and_wait(); // 0 -> 1
    if (get_speed_sel() !== 2'd1) $fatal(1, "Expected speed_sel=1, got %0d", get_speed_sel());
    observe_one_cycle($sformatf("speed%0d", get_speed_sel()));

    press_inc_and_wait(); // 1 -> 2
    if (get_speed_sel() !== 2'd2) $fatal(2, "Expected speed_sel=2, got %0d", get_speed_sel());
    observe_one_cycle($sformatf("speed%0d", get_speed_sel()));

    press_inc_and_wait(); // 2 -> 3
    if (get_speed_sel() !== 2'd3) $fatal(3, "Expected speed_sel=3, got %0d", get_speed_sel());
    observe_one_cycle($sformatf("speed%0d", get_speed_sel()));


    $display("YAHOO! test passed (ahw3_blink_top_tb)");
    $stop;
  end

endmodule
