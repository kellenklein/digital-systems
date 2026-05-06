`timescale 1ns/1ps

module speed_ctrl_tb;

  // DUT I/O
  logic       clk   = 0;
  logic       rst_n = 0;
  logic       speed_up = 0;
  logic       speed_down = 0;
  logic [1:0] speed_sel;

  // Instantiate DUT
  speed_ctrl dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .speed_up (speed_up),
    .speed_down (speed_down),
    .speed_sel (speed_sel)
  );

  // 100 MHz clock
  always #5 clk = ~clk;

  // ---------- helper tasks ----------

  // One-cycle INC pulse, then allow two clocks for update
  task automatic pulse_inc();
    begin
      speed_up = 1;
      @(posedge clk);
      speed_up = 0;
      @(posedge clk); @(posedge clk);
    end
  endtask

  // One-cycle DEC pulse, then allow two clocks for update
  task automatic pulse_dec();
    begin
      speed_down = 1;
      @(posedge clk);
      speed_down = 0;
      @(posedge clk); @(posedge clk);
    end
  endtask

  // Apply both pulses in the same cycle (should be no-op: inc_only=0, dec_only=0)
  task automatic pulse_both_same_cycle();
    begin
      speed_up = 1;
      speed_down = 1;
      @(posedge clk);
      speed_up = 0;
      speed_down = 0;
      @(posedge clk); @(posedge clk);
    end
  endtask

  // Expect helper with fatal on mismatch
  task automatic expect_speed(input int exp, input string tag);
    if (speed_sel !== exp[1:0]) begin
      $fatal(1, "[%s] Expected speed_sel=%0d, got %0d (t=%0t)",
                tag, exp, speed_sel, $time);
    end
    else begin
      $display("[%s] speed_sel=%0d OK (t=%0t)", tag, speed_sel, $time);
    end
  endtask

  // ---------- test sequence ----------
  initial begin
    $display("Running speed_ctrl_tb...");

    // Hold reset a few cycles
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    // After reset, expect 4 (MSB preset)
    expect_speed(0, "reset");

    // No pulse -> hold
    repeat (4) @(posedge clk);
    expect_speed(4, "hold-no-pulse");

    // Step faster 0->1->2->3->0
    pulse_inc(); expect_speed(1, "INC to 1");
    pulse_inc(); expect_speed(2, "INC to 2");
    pulse_inc(); expect_speed(3, "INC to 3");
    pulse_inc(); expect_speed(0, "overflow to 0");

    // Both pressed same cycle -> no-op (still 0)
    pulse_both_same_cycle(); expect_speed(0, "INC&DEC same cycle no-op");

    pulse_inc(); expect_speed(1, "INC to 1");
    pulse_inc(); expect_speed(2, "INC to 2");
    pulse_inc(); expect_speed(3, "INC to 3");

    // Step slower 3->2->1->0
    pulse_dec(); expect_speed(2, "DEC to 2");
    pulse_dec(); expect_speed(1, "DEC to 1");
    pulse_dec(); expect_speed(0, "DEC to 0");
    pulse_dec(); expect_speed(3, "underflow to 3");

    $display("YAHOO! test passed (speed_ctrl_tb)");
    $stop;
  end

endmodule