module cmp1bit(
  input 	A,				// incoming A-bit to compare
  input 	B,				// incoming B-bit to compare
  input 	AgtBi,			// bit below was greater
  input		AeqBi,			// bit below was equal
  input		AltBi,			// bit below was less
  output 	AgtBo,			// outgoing compare result
  output	AeqBo,			// outgoing compare result
  output	AltBo			// outgoing compare resul
);

  //////////////////////////////////////////
  // Declare any needed internal signals //
  ////////////////////////////////////////
logic equals_bit, greater_bit, lesser_bit, g_prev, l_prev;

  //////////////////////////////////////////////
  // Implement cmp1bit logic as structural   //
  // (placement of primitive gates) verilog //
  ///////////////////////////////////////////
xnor xnor0(equals_bit, A, B);
and and0(greater_bit, A, ~B);
nor nor0(lesser_bit, equals_bit, greater_bit);

and and1(AeqBo, equals_bit, AeqBi);

and and2(g_prev, equals_bit, AgtBi);
or or0(AgtBo, greater_bit, g_prev);

and and3(l_prev, equals_bit, AltBi);
or or1(AltBo, lesser_bit, l_prev);

endmodule  
