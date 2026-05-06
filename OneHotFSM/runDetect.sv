module runDetect(
  input clk,rst_n,			// system clock and active low asynch reset
  input strtCapCmp,			// initiates capture and comparison
  input [3:0] sig,			// input signal for capture/comparison
  output [3:0] N_abv		// output count of runs > 4
);

  ///////////////////////
  // Internal signals //
  /////////////////////
  wire cap;				// output of SM used to capture sig threshold (and zero N_abv)
  wire inc;				// output of SM that increments N_abv counter
  wire rst_run;			// output of SM that clears 2-bit run counter
  wire [3:0] thres;		// registered value of threshold
  wire gt;				// input to SM from mag4 comparator (new sample > threshold);
  wire run3;			// input to SM that indicates last 3 samples of run > threshold
  
  
  //////////////////////////////
  // Instantiate control FSM //
  ////////////////////////////
  FSM iDUT(.clk(clk), .rst_n(rst_n), .strtCapCmp(strtCapCmp), .gt(gt), .run3(run3),
           .cap(cap), .inc(inc),.rst_run(rst_run));
		   
  ////////////////////////////////////////////
  // Instantiate reg4 (captures threshold) //
  //////////////////////////////////////////
  reg4 iCAP(.clk(clk),.en(cap),.sig(sig),.thres(thres));
  
  ////////////////////////////////////////////
  // infer mag4 (no need to have a module) //
  //////////////////////////////////////////
  assign gt = (sig>thres) ? 1'b1 : 1'b0;
  
  /////////////////////////////////////
  // Instantiate cnt4 (drive N_abv) //
  ///////////////////////////////////
  cnt4 iABV(.clk(clk), .clr(cap), .inc(inc), .N_abv(N_abv));
  
  ////////////////////////////////////////////////////////////
  // Instantiate cnt2 (how many sample in run > threshold) //
  //////////////////////////////////////////////////////////
  cnt2 iRUNCNT(.clk(clk), .rst_cnt(rst_run), .TC(run3));
  
endmodule

/////// sub-modules defined below in same file for convenience ////////

module reg4 (clk,en,sig,thres);
  input clk;
  input en;					// active high enable
  input [3:0] sig;			// value to capture
  output reg [3:0] thres;	// captured value

  always_ff @(posedge clk)
    if (en)
	  thres <= sig;
	  
endmodule

module cnt4 (clk,clr,inc,N_abv);
  input clk;
  input clr;				// active high synch clears
  input inc;				// increment value
  output reg[3:0] N_abv;	// count of runs
  
  always_ff @(posedge clk)
    if (clr)
	  N_abv <= 4'h0;
	else if (inc)
	  N_abv <= N_abv + 1;
	
endmodule

module cnt2(clk,rst_cnt,TC);
  input clk;
  input rst_cnt;	// synch reset of count value
  output TC;		// Terminal Count (cnt = 2'b11)
  
  /// declare internal cnt value ///
  reg [1:0] cnt;
  
  always_ff @(posedge clk)
    if (rst_cnt)
	  cnt <= 2'b00;
	else
	  cnt <= cnt + 1;
	  
  assign TC = &cnt;
  
endmodule
	  
  




  