`timescale 1ns/1ps

module d_en_ff_tb;

  // DUT I/O (match your module)
  logic clk   = 0;
  logic rst_n = 0;   // active-low reset
  logic en    = 0;
  logic d     = 0;
  logic q;

  // Instantiate DUT
  d_en_ff dut (
    .clk  (clk),
    .rst_n(rst_n),
    .en   (en),
    .d    (d),
    .q    (q)
  ); 

  // 100 MHz clock
  always #5 clk = ~clk;

  // Helper (avoid 'expect' keyword)
  task automatic tb_check(input string msg, input bit cond);
    if (!cond) $fatal(1, "FAIL: %s (t=%0t)", msg, $time);
  endtask

  // Snapshot for hold checks
  logic q_snap;

  initial begin
    $display("Running d_en_ff_tb...");

    // Hold reset, then release
    rst_n = 0; en = 0; d = 0;
    repeat (2) @(posedge clk);
    tb_check("q==0 during reset", q === 1'b0);

    rst_n = 1;                // deassert reset 
    @(posedge clk); #1;
    tb_check("q remains 0 after reset release", q === 1'b0);

    // With en=0, q must hold regardless of d
    d = 1;
    repeat (3) @(posedge clk); #1;
    tb_check("q holds when en=0 (d changes ignored)", q === 1'b0);

    // With en=1, q captures d on clock edge
    en = 1;
    @(posedge clk); #1;
    tb_check("q captured d=1 when en=1", q === 1'b1);

    // Change d while en=1; q updates on next edge
    d = 0;
    @(posedge clk); #1;
    tb_check("q captured d=0 on next edge (en=1)", q === 1'b0);

    // Back to en=0; q must hold even if d toggles
    en = 0;
    q_snap = q;
    d = ~d; @(posedge clk); #1; tb_check("hold with en=0 (step1)", q === q_snap);
    d = ~d; @(posedge clk); #1; tb_check("hold with en=0 (step2)", q === q_snap);

    // Async clear via active-low rst_n should win immediately
    d = 1; en = 1;
    #1; rst_n = 0; #1;
    tb_check("async clear drives q=0 immediately", q === 1'b0);
    rst_n = 1;

    // After clear, with en=1, q resumes capturing
    d = 1; @(posedge clk); #1; tb_check("post-clear capture d=1", q === 1'b1);
    d = 0; @(posedge clk); #1; tb_check("post-clear capture d=0", q === 1'b0);

    $display("YAHOO! test passed (d_en_ff_tb)");
    $stop;
  end

endmodule
