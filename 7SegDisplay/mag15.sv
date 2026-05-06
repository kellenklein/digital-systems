module mag15(
  input [14:0] A,	// number to compare
  input [14:0] B,	// number to compare
  output AgtB,		// A>B
  output AeqB,		// A==B
  output AltB		// A<B
);

  ////////////////////////////////////////////////////////////
  // Connections from AgtBo --> AgtBi, etc. made by vector //
  //////////////////////////////////////////////////////////
  logic [14:0] gt_vec;	// used to interconnect the gt sigs
  logic [14:0] eq_vec;	// used to interconnect the eq sigs
  logic [14:0] lt_vec;	// used to interconnect the lt sigs
  
  ///////////////////////////////////////
  // Instantiate 16-copies of cmp1bit //
  /////////////////////////////////////
  // Changed it to 15 copies otherwise it won't compile with the 15 bit
  // vectors
  cmp1bit iCMP[14:0](.A(A), .B(B), .AgtBi({gt_vec[13:0],1'b0}),
                     .AeqBi({eq_vec[13:0],1'b1}), .AltBi({lt_vec[13:0],1'b0}),
					 .AgtBo(gt_vec), .AeqBo(eq_vec), .AltBo(lt_vec));
					
  assign AgtB = gt_vec[14];
  assign AeqB = eq_vec[14];
  assign AltB = lt_vec[14];
					
endmodule
