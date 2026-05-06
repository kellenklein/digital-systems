//-----------------------------------------------------------------------------
// claw_fsm_onehot.sv
// One-hot FSM implementation of the claw game controller
// Behavior matches claw_fsm.sv (2-bit encoded version).
//
// One-hot state bits:
//   idle   = in IDLE state
//   sweep  = in SWEEP state
//   result = in RESULT state
//   show   = in SHOW state
//-----------------------------------------------------------------------------

module claw_fsm_onehot (
    input  logic clk,
    input  logic rst_n,   // active-low global reset 

    input  logic start_pulse,
    input  logic grab_pulse,
    input  logic timer_zero,
    input  logic hit,
    input  logic attempts_lt5,
    input  logic attempts_eq5,

    output logic obj_ld,
    output logic sweep_en,
    output logic tmr_ld,
    output logic tmr_en,
    output logic score_inc,
    output logic score_dec,
    output logic score_clr,
    output logic attempts_inc,
    output logic attempts_clr
);

    // One-hot state registers
    logic idle,   idle_d;
    logic sweep,  sweep_d;
    logic result, result_d;
    logic show,   show_d;

  

    //--------------------------------------------------------------------------
    // TODO:
    // State flip-flops: one d_ff per state bit
    // 
    // Decide which state(s) should be active immediately after reset,
    // and make sure your logic guarantees a valid starting state.
    //--------------------------------------------------------------------------
    d_ff idle_ff(.clk(clk), .CLRN(1'b1), .PRN(rst_n), .D(idle_d), .Q(idle));
    d_ff sweep_ff(.clk(clk), .CLRN(rst_n), .PRN(1'b1), .D(sweep_d), .Q(sweep));
    d_ff result_ff(.clk(clk), .CLRN(rst_n), .PRN(1'b1), .D(result_d), .Q(result));
    d_ff show_ff(.clk(clk), .CLRN(rst_n), .PRN(1'b1), .D(show_d), .Q(show));

    //--------------------------------------------------------------------------
    // TODO: Next-state equations (D inputs) derived from the behavioral FSM
    //--------------------------------------------------------------------------

    // IDLE next-state:
    assign idle_d = (~start_pulse & idle) | (attempts_eq5 & show);/* TODO: fill in your IDLE D-input equation */;
    assign sweep_d = (start_pulse & idle) | ((~timer_zero & ~grab_pulse) & sweep) | (attempts_lt5 & show);
    assign result_d = ((timer_zero | grab_pulse) & sweep);
    assign show_d = (result & ~hit) | (result & hit);
    // TODO: do the same for SWEEP, RESULT, and SHOW:



    //--------------------------------------------------------------------------
    // TODO: Outputs equations(Mealy), same behavior as in claw_fsm.sv
    //--------------------------------------------------------------------------
    assign obj_ld       = idle & start_pulse;
    assign score_clr = idle & start_pulse;
    assign attempts_clr = idle &  start_pulse;
    assign tmr_ld = (idle & start_pulse) | (show & attempts_lt5);
    assign attempts_inc = (sweep & (timer_zero | grab_pulse));
    assign score_dec = result & ~hit;
    assign score_inc = result & hit;
    
    // TODO: write equations for the remaining outputs:

endmodule
