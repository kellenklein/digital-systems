//-----------------------------------------------------------------------------
// score_reg.sv 
//-----------------------------------------------------------------------------
// Score register for the claw game.
//
// Behavior:
//   - On score_clr:      score = 5
//   - On score_inc:      score = score + 1
//   - On score_dec:      score = score - 1
//   - Otherwise: hold previous value
//
// Requirements:
//   - Use only combinational assign statements for next_score
//   - Use d_en_ff[WIDTH-1:0] flip-flops for storage
//   - No always_ff or always_comb
//-----------------------------------------------------------------------------

module score_reg #(
    parameter int WIDTH = 4
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             score_inc,
    input  logic             score_dec,
    input  logic             score_clr,
    output logic [WIDTH-1:0] score
);

    logic [WIDTH-1:0] next_score;
    logic             score_en_ff;

    // TODO: assign next_score using score_inc, score_dec, score_clr, and score
    //       Use dataflow implementation
    assign next_score = score_clr ? 5 : (score_inc ? score + 1 : (score_dec ? score - 1 : score));
    

    // TODO: drive score_en_ff (should be 1 when score changes)
    assign score_en_ff = score_clr | score_inc | score_dec;

    // TODO: instantiate d_en_ff[WIDTH-1:0]
    d_en_ff score_ff[WIDTH-1:0](.clk(clk), .rst_n(rst_n), .en(score_en_ff), .d(next_score), .q(score));

endmodule
