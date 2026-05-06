module runDetect_tb();

  ////// Declare stimulus of type reg ///////
  reg clk,rst_n;		// clock & reset
  reg strtCapCmp;		// initiate capture/compare
  reg [3:0] sig;		// data value for capture/compare
  reg error;			// flag for keeping track if test encountered error
  
  ///// Declare signal to monitor DUT output //////
  wire [3:0] N_abv;
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  runDetect iDUT(.clk(clk), .rst_n(rst_n), .strtCapCmp(strtCapCmp),
                 .sig(sig), .N_abv(N_abv));
				 
  /////////////////////////////////////////
  // Now for main testing initial block //
  ///////////////////////////////////////
  initial begin
    error = 0;			// error flag (innocent till proven guilty)
    clk = 0;
	rst_n = 0;
	sig = 4'h3;
	strtCapCmp = 0;
	@(negedge clk);
	rst_n = 1;			// deassert reset
	
	@(negedge clk);		// wait 1 clock before changing sig and asserting strtCapCmp
	sig = 4'h5;			// this is value that should be captured as threshold
	strtCapCmp = 1;		// initiate the capture
	@(negedge clk);
	strtCapCmp = 0;
	sig = 4'h6;			// 1st value >
	@(negedge clk);
	sig = 4'h8;			// 2nd value >
	@(negedge clk);
	sig = 4'h9;			// 3rd value >
	@(negedge clk);
	sig = 4'h3;			// 4th value <
	@(negedge clk);
	if (N_abv!==4'h0) begin
	  $display("ERR: at time %t N_abv should still be zero since 4th sample not gt",$time);
	  error = 1;
	end else
	  $display("GOOD! test 1 passes");
	sig = 4'h6;			// 1st value >
	@(negedge clk);
	sig = 4'h8;			// 2nd value >
	@(negedge clk);
	sig = 4'h9;			// 3rd value >
	@(negedge clk);
	sig = 4'h7;			// 4th value >
	@(negedge clk);	
	if (N_abv!==4'h1) begin
	  $display("ERR: at time %t N_abv should have incremented to 1",$time);
	  error = 1;
	end	else
	  $display("GOOD! test 2 passes");
	  
	/// Now hold it greater for 4 more clocks to 
	/// ensure we do not increment before a 
	/// sample is below the threshold 
	///
	repeat(7) @(negedge clk);
	if (N_abv!==4'h1) begin
	  $display("ERR: at time %t, values have maintained above threshold so 2nd increment not possible",$time);
	  error = 1;
	end	else
	  $display("GOOD! test 3 passes");
	  
	  
	sig = 4'h5; 	// a value <= threshold should allow for incrementing
	@(negedge clk);
	sig = 4'h8;			// 1st value >
	@(negedge clk);
	sig = 4'h7;			// 2nd value >
	@(negedge clk);
	sig = 4'h6;			// 3rd value >
	@(negedge clk);
	if (N_abv!==4'h1) begin
	  $display("ERR: at time %t N_abv should still be 1",$time);
	  error = 1;
	end	else
	  $display("GOOD! test 4 passes");
	sig = 4'h9;			// 4th value >
	@(negedge clk);
	if (N_abv!==4'h2) begin
	  $display("ERR: at time %t N_abv should have incremented to 2",$time);
	  error = 1;
	end	else
	  $display("GOOD! test 5 passes");
	  
	//// Last check intended to see if 
	//// cnt2 being reset when returning 
	//// to look for another run 
	@(negedge clk);
	sig = 4'h2;					// should go back to looking for run on next clock
	@(negedge clk);
	sig = 4'h6;
	repeat(2) @(negedge clk);
	sig = 4'h9;
	@(negedge clk);	
	if (N_abv!==4'h2) begin
	  $display("ERR: at time %t N_abv should still be 2",$time);
	  error = 1;
	end	else
	  $display("GOOD! test 6 passes");	  
	sig = 4'hB;
	@(negedge clk);
	sig = 4'hA;
	@(negedge clk);
	if (N_abv!==4'h3) begin
	  $display("ERR: at time %t N_abv should have incremented to 3",$time);
	  error = 1;
	end	else
	  $display("GOOD! test 7 passes");
	repeat(2) @(negedge clk);
	  
	  
	if (error)
	  $display("ERRORs exist continue debugging");
	else
	  $display("YAHOO!! all tests pass!");
	$stop();
	
  end
  
  always
    #5 clk = ~clk;
	
endmodule
