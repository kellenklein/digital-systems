//-----------------------------------------------------------------------------
// attempts_reg.sv  
//-----------------------------------------------------------------------------
// Attempts counter for the claw game.
//
// Behavior:
//   - On attempts_clr: attempts = 0
//   - On attempts_inc:
//         if attempts < 5: attempts = attempts + 1
//         else:            attempts stays at 5 (saturates)
//   - attempts_lt5 = 1 when attempts < 5
//   - attempts_eq5 = 1 when attempts == 5
//
// Requirements:
//   - Use combinational assign statements for next_attempts
//   - Use d_en_ff[2:0] flip-flops to store attempts
//   - No always_ff / always_comb in this file
//-----------------------------------------------------------------------------

module attempts_reg (
    input  logic       clk,
    input  logic       rst_n,          // async active-low reset
    input  logic       attempts_inc,
    input  logic       attempts_clr,
    output logic [2:0] attempts,
    output logic       attempts_lt5,
    output logic       attempts_eq5
);

    logic [2:0] next_attempts;
    logic       attempts_en_ff;

    // TODO: drive attempts_lt5 and attempts_eq5 from attempts
    assign attempts_lt5 = attempts < 3'b101;
    assign attempts_eq5 = attempts == 3'b101;

    // TODO: assign next_attempts 
    assign next_attempts = (attempts_clr ? 1'b0 : (attempts_inc ? (attempts_lt5 ? attempts + 1 : attempts) : attempts));


    // TODO: set attempts_en_ff so that flip-flops update when
    //       attempts_clr or attempts_inc is asserted
    assign attempts_en_ff = attempts_clr | attempts_inc;
    

    // TODO: instantiate d_en_ff[2:0] for attempts
    d_en_ff attempts_ff[2:0](.clk(clk), .rst_n(rst_n), .en(attempts_en_ff), .d(next_attempts), .q(attempts));

endmodule
