//-----------------------------------------------------------------------------
// claw_fsm.sv  (STUDENT FILE)
//-----------------------------------------------------------------------------
// Behavioral (case-based) Mealy FSM for the claw game controller.
//
// States (fixed):
//   IDLE   - wait for game start
//   SWEEP  - sweep window and run timer
//   RESULT - evaluate current attempt
//   SHOW   - prepare for next attempt or end game
//
// You will complete the next-state and output logic in the always_comb block.
// Do NOT change the module name, ports, or state type.
//-----------------------------------------------------------------------------

module claw_fsm (
    input  logic clk,
    input  logic rst_n,          // asynchronous active-low reset

    // FSM inputs
    input  logic start_pulse,
    input  logic grab_pulse,
    input  logic timer_zero,
    input  logic hit,
    input  logic attempts_lt5,
    input  logic attempts_eq5,

    // Control outputs to datapath
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

    //-------------------------------------------------------------------------
    // State encoding (fixed)
    //-------------------------------------------------------------------------
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        SWEEP  = 2'b01,
        RESULT = 2'b10,
        SHOW   = 2'b11
    } state_t;

    state_t state, next_state;

    //-------------------------------------------------------------------------
    // State register
    //-------------------------------------------------------------------------
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    //-------------------------------------------------------------------------
    // Next-state and output logic
    //-------------------------------------------------------------------------
    always_comb begin
        //---------------------------------------------------------------------
        // State-dependent behavior:
        // Figure out next_state and control outputs to datapath
        //---------------------------------------------------------------------
        unique case (state)

            // IDLE: waiting for a new game to start.
            IDLE: begin
                // TODO: implement IDLE behavior
                next_state = start_pulse ? SWEEP : IDLE;
                obj_ld = start_pulse ? 1'b1 : 1'b0;
                score_clr = start_pulse ? 1'b1 : 1'b0;
                attempts_clr = start_pulse ? 1'b1 : 1'b0;
                tmr_ld = start_pulse ? 1'b1 : 1'b0;
            end

            // SWEEP: window is moving, timer is running.
            SWEEP: begin
                score_clr = 1'b0;
                attempts_clr = 1'b0;
                tmr_ld = 1'b0;

                next_state = (timer_zero | grab_pulse) ? RESULT : SWEEP;
                sweep_en = (timer_zero | grab_pulse) ? 1'b0 : 1'b1;
                tmr_en = (timer_zero | grab_pulse) ? 1'b0 : 1'b1;
                attempts_inc = (timer_zero | grab_pulse) ? 1'b1 : 1'b0; 
            end

            // RESULT: one attempt has completed (grab or timeout).
            RESULT: begin
                attempts_inc = 1'b0;
                next_state = SHOW;
                score_inc = hit ? 1'b1 : 1'b0;
                score_dec = hit ? 1'b0 : 1'b1;
            end

            // SHOW: decide whether to continue (new attempt) or end game.
            SHOW: begin
                // TODO: implement SHOW behavior
                score_inc = 1'b0;
                score_dec = 1'b0;
                next_state = (attempts_lt5 & ~attempts_eq5) ? SWEEP : IDLE;
                tmr_ld = (attempts_lt5 & ~attempts_eq5) ? 1'b1 : 1'b0;  
            end

            // Safety fallback
            default: begin
                obj_ld        = 1'b0;
                sweep_en      = 1'b0;
                tmr_ld        = 1'b0;
                tmr_en        = 1'b0;
                score_inc     = 1'b0;
                score_dec     = 1'b0;
                score_clr     = 1'b0;
                attempts_inc  = 1'b0;
                attempts_clr  = 1'b0;

                next_state = IDLE;
            end

        endcase
    end

endmodule
