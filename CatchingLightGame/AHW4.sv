//-----------------------------------------------------------------------------
// AHW4.sv  – Top-level for Applied Homework 4 (Claw Game)
//-----------------------------------------------------------------------------
// Board connections:
//   clk           : board clock
//   rst_n         : global active-low reset
//   SW[17:0]      : object position selection (one-hot)
//   KEY[0]        : START (edge-detected)
//   KEY[1]        : GRAB (edge-detected)
//   KEY[2]        : SCORE RESET (edge-detected)
//   LEDR[17:0]    : moving window LEDs (top row)
//   HEX0[6:0]     : shows low 4 bits of score
//-----------------------------------------------------------------------------

module AHW4 (
    input  logic        clk,
    input  logic [17:0] SW,
    input  logic [3:0]  KEY,
    output logic [17:0] LEDR,
	 output logic [3:0] LEDG,
    output logic [6:0]  HEX0,
	output logic [6:0]  HEX1
);

    //--------------------------------------------------------------------------
    // Local signals
    //--------------------------------------------------------------------------

	 //reset
	 logic rst_n;
	 
    // Edge-detected control pulses
    logic start_pulse;
    logic grab_pulse;
    logic score_clr_key;

    // Slow tick from clock divider (for timer & sweep)
    logic tick;

    // FSM <-> datapath control wires
    logic obj_ld;
    logic sweep_en;
    logic tmr_ld;
    logic tmr_en;
    logic score_inc;
    logic score_dec;
    logic score_clr_fsm;
    logic attempts_inc;
    logic attempts_clr;

    // Datapath state signals
    logic [17:0] obj_mask;
    logic [17:0] window_mask;

    logic [7:0]  tmr_val;
    logic        timer_zero;

    logic [3:0]  score;
    logic        score_clr_total;

    logic [2:0]  attempts;
    logic        attempts_lt5;
    logic        attempts_eq5;

    logic        hit;
	 

	// rst_n active low signal
	
	assign rst_n = KEY[3];
		
	
    //--------------------------------------------------------------------------
    // Clock divider for game tick (sweep + timer)
    // Adjust parameters of clkdivN in your own file as needed for visual speed.
    //--------------------------------------------------------------------------

    clkdivN clkdiv_inst (
        .clk   (clk),
        .rst_n (rst_n),
        .tick  (tick),
		  .speed_sel (2'b11)
    );

    //--------------------------------------------------------------------------
    // Edge detectors for keys
    // Assumes rise_edge_detect has ports: (clk, rst_n, sig, rise)
    // NOTE: DE2/DE1 keys are active-LOW, so we invert them.
    //--------------------------------------------------------------------------

    wire key_start_raw  = ~KEY[0];
    wire key_grab_raw   = ~KEY[1];
    wire key_score_raw  = ~KEY[2];
	 
	assign LEDG[0] = ~KEY[0]; 
	assign LEDG[1] = ~KEY[1]; 
	assign LEDG[2] = ~KEY[2];
	assign LEDG[3] = ~KEY[3];  

    rise_edge_detect start_ed (
        .clk  (clk),
        .rst_n(rst_n),
        .sig  (key_start_raw),
        .sig_rise (start_pulse)
    );

    rise_edge_detect grab_ed (
        .clk  (clk),
        .rst_n(rst_n),
        .sig  (key_grab_raw),
        .sig_rise (grab_pulse)
    );

    rise_edge_detect score_ed (
        .clk  (clk),
        .rst_n(rst_n),
        .sig  (key_score_raw),
        .sig_rise (score_clr_key)
    );

    //--------------------------------------------------------------------------
    // One-hot FSM controller
    //--------------------------------------------------------------------------

    claw_fsm_onehot fsm (
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
        .score_clr    (score_clr_fsm),   // from FSM (optional)
        .attempts_inc (attempts_inc),
        .attempts_clr (attempts_clr)
    );

    // Combine FSM-driven score clear and KEY[2]-driven clear.
    // If you decide that ONLY KEY[2] should clear the score,
    // you can just use score_clr_key and ignore score_clr_fsm.
    assign score_clr_total = score_clr_fsm | score_clr_key;

    //--------------------------------------------------------------------------
    // Object register – latches SW[17:0] at game start (obj_ld)
    //--------------------------------------------------------------------------

    obj_reg obj_reg_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .obj_ld  (obj_ld),
        .sw_in   (SW),
        .obj_mask(obj_mask)
    );

    //--------------------------------------------------------------------------
    // Attempts register – counts up to 5 attempts
    //--------------------------------------------------------------------------

    attempts_reg attempts_inst (
        .clk          (clk),
        .rst_n        (rst_n),
        .attempts_inc (attempts_inc),
        .attempts_clr (attempts_clr),
        .attempts     (attempts),
        .attempts_lt5 (attempts_lt5),
        .attempts_eq5 (attempts_eq5)
    );

    //--------------------------------------------------------------------------
    // Timer register – round countdown
    // WIDTH and ROUND_MAX can be tuned later depending on tick frequency.
    //--------------------------------------------------------------------------

    timer_reg #(
        .WIDTH    (16),
        .ROUND_MAX(16'd200)   // adjust as needed for visible timeout
    ) timer_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .tick       (tick),
        .tmr_ld     (tmr_ld),
        .tmr_en     (tmr_en),
        .tmr_val    (tmr_val),
        .timer_zero (timer_zero)
    );

    //--------------------------------------------------------------------------
    // Score register – tracks player score
    //--------------------------------------------------------------------------

    score_reg #(
        .WIDTH(4)
    ) score_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .score_inc (score_inc),
        .score_dec (score_dec),
        .score_clr (score_clr_total),
        .score     (score)
    );

    //--------------------------------------------------------------------------
    // Window sweep controller – drives LEDR[17:0]
    // Uses the same tick as timer_reg or you can use a separate divider
    // if you want independent speeds.
//--------------------------------------------------------------------------

    sweep_ctrl #(
        .N_LEDS   (18),
        .WIN_WIDTH(3)    // adjust width of the sweeping window if desired
    ) sweep_inst (
        .sweep_clk (tick),
		  .rst_n 	 (rst_n),
        .sweep_en  (sweep_en),
        .led_window(window_mask)
    );

    assign LEDR = window_mask;

    //--------------------------------------------------------------------------
    // Hit detector – checks overlap of window and object
    //--------------------------------------------------------------------------

    hit_detector hit_inst (
        .window_mask(window_mask),
        .obj_mask   (obj_mask),
        .hit        (hit)
    );

    //--------------------------------------------------------------------------
    // 7-segment display 
//--------------------------------------------------------------------------

    logic [3:0] tens;
	logic [3:0] ones;

    assign tens = (score >= 10) ? 4'd1 : 4'd0;
    assign ones = (score >= 10) ? (score - 10) : score;

    // drive with your existing bcd7seg decoders
    bcd7seg u_tens (.num(tens), .seg(HEX1));
    bcd7seg u_ones (.num(ones), .seg(HEX0));
		
	
    

endmodule

