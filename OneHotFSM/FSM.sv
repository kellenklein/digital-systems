////////////////////////////////////////////////\\
// FSM.sv : Control FSM for runDetect block      \\
// that detects a run of numbers of length        \\
// 4 or greater that are all greater than          \\
// a threshold.                                     \\
//                                                  //
// Student 1 Name: Kellen Klein                    //
// Student 2 Name: << Enter name if applicable >> //
///////////////////////////////////////////////////
module FSM(
  input clk, 			// system clock
  input rst_n,			// active low asynch reset
  input strtCapCmp,		// initiate capture and compare
  input gt,				// current sig > threshold
  input run3,			// currently 3 prev values of sig > threshold
  output logic cap,		// capture sig value as threshold and clear N_abv
  output logic inc,		// inc N_abv counter
  output logic rst_run	// reset the run counter
);

  ///////////////////////////////////////////////////////////////////////
  // NOTE: you may need to modify this for different number of states //
  // The IDLE state has been named for you.  Give your other states  //
  // meaningful names.                                              //
  ///////////////////////////////////////////////////////////////////
  typedef enum reg[2:0] {IDLE=3'b001, READ=3'b010, PAUSE=3'b100} state_t;
  
  ///////////////////////////////////////
  // Declare nxt_state of our state_t //
  /////////////////////////////////////
  state_t nxt_state;
  
  //////////////////////////////////
  // Declare any internal signsl //
  ////////////////////////////////
  logic [2:0] state;		// might have to change width depending on # of states
  
  //////////////////////////////////////////////////////////
  // Instantiate state flops                             //
  // NOTE: perhaps you need a state4_reg or different?? //
  ///////////////////////////////////////////////////////
  state3_reg iST(.clk(clk), .rst_n(rst_n), .nxt_state(nxt_state), .state(state));
  
  //////////////////////////////////////////////
  // State transitions and outputs specified //
  // next as combinational logic with case  //
  ///////////////////////////////////////////		
  always_comb begin
	/////////////////////////////////////////////////////////////
	// Default all SM outputs & nxt_state                     //
	// OK nxt_state is done for you.  You default SM outputs //
	//////////////////////////////////////////////////////////
	nxt_state = state_t'(state);
  cap = 1'b0;
  inc = 1'b0;
  rst_run = 1'b0;
	
	case (state)
	  IDLE: begin
      nxt_state = strtCapCmp ? READ : IDLE;
      rst_run = strtCapCmp ? 1'b1 : 1'b0;
      cap = strtCapCmp ? 1'b1 : 1'b0;
	  end
    
    READ: begin
      nxt_state = (run3 & gt) ? PAUSE : READ;
      rst_run = (~gt) ? 1'b1 : 1'b0;
      inc = (run3 & gt) ? 1'b1 : 1'b0;
    end

    PAUSE: begin
      nxt_state = (~gt) ? READ : PAUSE;
      rst_run = (~gt) ? 1'b1: 1'b0;
    end
	endcase
  end
		
endmodule
