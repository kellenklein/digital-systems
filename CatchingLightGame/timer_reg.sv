//-----------------------------------------------------------------------------
// timer_reg.sv 
//-----------------------------------------------------------------------------
// Round timer for the claw game.
//
// Behavior:
//   - On reset:                  tmr_val = 0
//   - On tmr_ld = 1:             tmr_val = ROUND_MAX
//   - Else if tmr_en && tick
//         and tmr_val > 0:       tmr_val = tmr_val - 1
//   - Otherwise:                 hold previous value
//
// Implement using:
//   - combinational logic for next_tmr_val
//   - vector of d_en_ff flip-flops to store tmr_val
//
// Do NOT use always_ff; all storage must go through d_en_ff.
//-----------------------------------------------------------------------------

module timer_reg #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] ROUND_MAX = 8'd20
) (
    input  logic              clk,
    input  logic              rst_n,       // async active-low reset
    input  logic              tick,        // slow tick (from clkdivN)
    input  logic              tmr_ld,      // load timer
    input  logic              tmr_en,      // enable countdown
    output logic [WIDTH-1:0]  tmr_val,     // current timer value
    output logic              timer_zero   // 1 when tmr_val == 0
);

    logic [WIDTH-1:0] next_tmr_val;
    logic             tmr_en_ff;

    // TODO: drive timer_zero based on tmr_val
    assign timer_zero = tmr_val <= 1'b0;

    // TODO: assign next_tmr_val using:
    //       - ROUND_MAX when loading
    //       - (tmr_val - 1) when decrementing
    //       - otherwise hold current tmr_val
    assign next_tmr_val = (tmr_ld) ? ROUND_MAX : (((tmr_en & tick) & (~timer_zero)) ? (tmr_val - 1) : tmr_val);

    // TODO: tmr_en_ff should be 1 only when the FFs must update
    //       (either load OR decrement)
    assign tmr_en_ff = tmr_ld | (tmr_en & tick);

    // TODO: instantiate d_en_ff[WIDTH-1:0] to store tmr_val
    d_en_ff tmr_ff[WIDTH-1:0](.clk(clk), .rst_n(rst_n), .en(tmr_en_ff), .d(next_tmr_val), .q(tmr_val));

endmodule
