`timescale 1ns/1ps
/////////////////////////////////////////////////////////
// ahw3_blink_top.sv: Top-level for Adjustable Blinker //
// - Buttons go through rise_edge_detect (sync + pulse)//
// - speed_ctrl selects divider rate (0=fast .. 4=slow)//
// - clkdivN generates tick                           //
// - 8-bit LED register toggles on tick using d_en_ff //
/////////////////////////////////////////////////////////
module ahw3_blink_top (
  input  logic       clk,       // system clock
  input  logic       rst_n,     // active-low reset
  input  logic       btn_inc,   // increase speed (faster)
  input  logic       btn_dec,   // decrease speed (slower)
  output logic [7:0] led        // LEDs
);

  // ----------------- Wires -----------------
  logic        speed_up, speed_down;   // 1-cycle pulses from buttons
  logic [1:0]  speed_sel;              // 0=fastest .. 4=slowest
  logic        tick;                 // divider enable pulse
  logic [7:0]  led_nxt;                // next LED state (bitwise toggle)

  // ----------------- Edge detectors -----------------
  // Buttons assumed idle-high (typical pull-up + active-low press wiring)
  rise_edge_detect u_inc (
    .clk     (clk),
    .rst_n   (rst_n),
    .sig     (btn_inc),
    .sig_rise(speed_up)
  );

  rise_edge_detect u_dec (
    .clk     (clk),
    .rst_n   (rst_n),
    .sig     (btn_dec),
    .sig_rise(speed_down)
  );

  // ----------------- Speed control -----------------
  // INC makes it faster (count down toward 0), DEC slower (up toward 4).
  speed_ctrl u_spd (
    .clk       (clk),
    .rst_n     (rst_n),
    .speed_up (speed_up),
    .speed_down (speed_down),
    .speed_sel (speed_sel)
  );

  // ----------------- Clock divider -----------------
  // Maps speed_sel to terminal counts (e.g., 0→2^6, 1→2^8, …, 4→2^14) and
  // emits a 1-cycle tick pulse at that rate.
  clkdivN u_div (
    .clk       (clk),
    .rst_n     (rst_n),
    .speed_sel (speed_sel),
    .tick    (tick)
  );

  // ----------------- LED register (toggle) -----------------
  // Build an 8-bit register from d_en_ff cells; each bit toggles on tick.
  assign led_nxt = ~led;


 // ---------- 8-bit register ------------
 // TODO: instantiate your d_en_ff here as a vector
  d_en_ff d_en_ff_vec[7:0](.clk(clk), .rst_n(rst_n), .en(tick), .d(~led[7:0]), .q(led[7:0]));


 

endmodule
 
