module mag15_tb();

  reg [14:0] A_stim, B_stim;		// 12-bit vectors being compared
  reg error;
  
  wire [2:0] result;			// hooks to {AgtB,AeqB,AltB} of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  mag15 iDUT(.A(A_stim), .B(B_stim), .AgtB(result[2]), .AeqB(result[1]), .AltB(result[0]));
  
  initial begin
    error = 1'b0;		// innocent till proven guilty
	A_stim = 15'h7FDD;
	B_stim = 15'h7FDC;
	#5;
	if (result!==3'b100) begin
	  $display("ERR: at time %t results are wrong, only AgtB should be asserted",$time);
	  error = 1'b1;
	end else $display("GOOD: test0 passed");

	A_stim = 15'h7FAA;
	B_stim = 15'h7FAA;
	#5;
	if (result!==3'b010) begin
	  $display("ERR: at time %t results are wrong, only AeqB should be asserted",$time);
	  error = 1'b1;
	end else $display("GOOD: test1 passed");

	A_stim = 15'h4000;
	B_stim = 15'h3FFF;
	#5;
	if (result!==3'b100) begin
	  $display("ERR: at time %t results are wrong, only AgtB should be asserted",$time);
	  error = 1'b1;
	end else $display("GOOD: test2 passed");
	
	A_stim = 15'h7FFE;
	B_stim = 15'h7FFF;
	#5;
	if (result!==3'b001) begin
	  $display("ERR: at time %t results are wrong, only AltB should be asserted",$time);
	  error = 1'b1;
	end else $display("GOOD: test3 passed");
	
	A_stim = 15'h5555;
	B_stim = 15'h5AAA;
	#5;
	if (result!==3'b001) begin
	  $display("ERR: at time %t results are wrong, only AltB should be asserted",$time);
	  error = 1'b1;
	end else $display("GOOD: test4 passed");
	
	A_stim = 15'h0000;
	B_stim = 15'h0000;
	#5;
	if (result!==3'b010) begin
	  $display("ERR: at time %t results are wrong, only AeqB should be asserted",$time);
	  error = 1'b1;
	end else $display("GOOD: test5 passed");
	
	if (!error)
	  $display("YAHOO!! test of mag15 passed!");
	$stop();
  
  end
  
endmodule