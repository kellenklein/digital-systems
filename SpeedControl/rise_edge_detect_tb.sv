`timescale 1ns/1ps

module rise_edge_detect_tb;

  // DUT I/O
  logic clk = 0;
  logic rst_n = 0;      // active-low reset
  logic sig   = 1;      // idle-high button signal
  logic sig_rise;

  // Instantiate DUT (matches your naming/ports)
  rise_edge_detect dut (
    .clk     (clk),
    .rst_n   (rst_n),
    .sig     (sig),
    .sig_rise(sig_rise)
  );

  // 100 MHz clock
  always #5 clk = ~clk;

  // ---------------- Helper tasks ----------------

  // Drive a clean RISING edge on 'sig' mid-cycle (async to clk)
  task automatic drive_rise(string tag);
    // ensure it's low first, then rise between clock edges
    sig = 0;
    repeat (2) @(posedge clk);
    @(negedge clk); #1; sig = 1;
    $display("[%s] drove RISE on sig at t=%0t", tag, $time);
  endtask

  // Drive a clean FALLING edge on 'sig' mid-cycle
  task automatic drive_fall(string tag);
    sig = 1;
    repeat (2) @(posedge clk);
    @(negedge clk); #1; sig = 0;
    $display("[%s] drove FALL on sig at t=%0t", tag, $time);
  endtask

  // Confirm no pulse appears over N cycles
  task automatic expect_no_pulse(string tag, int N);
    int i;
    for (i = 0; i < N; i++) begin
      @(posedge clk); #1;
      if (sig_rise === 1'b1)
        $fatal(1, "[%s] unexpected sig_rise=1 at t=%0t", tag, $time);
    end
    $display("[%s] no pulse observed over %0d cycles", tag, N);
  endtask

  // After a RISE on 'sig', expect exactly ONE 1-cycle pulse on sig_rise.
  // (Accounts for the 2-FF sync + 1-FF 'last' latency.)
  task automatic expect_one_pulse(string tag);
    bit seen = 0;
    int guard = 8; // max cycles to wait for the pulse
    // Wait up to 'guard' cycles for a 1-cycle pulse
    while (!seen && guard > 0) begin
      @(posedge clk); #1;
      if (sig_rise === 1'b1) seen = 1;
      guard--;
    end
    if (!seen) $fatal(1, "[%s] no pulse detected within window (t=%0t)", tag, $time);

    // Next cycle it must be back to 0
    @(posedge clk); #1;
    if (sig_rise !== 1'b0)
      $fatal(1, "[%s] pulse lasted more than 1 cycle (t=%0t)", tag, $time);

    $display("[%s] saw exactly one 1-cycle pulse", tag);
  endtask

  // ---------------- Test sequence ----------------
  initial begin
    $display("Running rise_edge_detect_tb...");

    // Hold reset; with your preset scheme, flops start at 1 and no pulse should occur
    sig   = 1;
    rst_n = 0;
    repeat (5) @(posedge clk);

    // Release reset and ensure no spurious pulse
    rst_n = 1;
    expect_no_pulse("after_reset", 5);

    // A FALLING edge should NOT produce a pulse
    drive_fall("fall_1");
    expect_no_pulse("check_fall_1", 8);

    // A RISING edge should produce exactly one 1-cycle pulse
    drive_rise("rise_1");
    expect_one_pulse("check_rise_1");

    // Another RISING edge later → exactly one pulse
    drive_rise("rise_2");
    expect_one_pulse("check_rise_2");

    // // Simple "bounce" pattern: 1->0->1 quickly; still expect a single pulse overall
    // // (given the sync chain, only the final settled rising transition should count)
    // sig = 1;
    // @(negedge clk); #1; sig = 0;  // fall
    // #2;               sig = 1;    // quick rise
    // expect_one_pulse("bounce_final_rise");

    $display("YAHOO! test passed (rise_edge_detect_tb)");
    $stop;
  end

endmodule