///////////////////////////////////////////////////
// FA.sv  This design will take in 3 bits       //
// and add them to produce a sum and carry out //
////////////////////////////////////////////////
module FA(input A, input B, input Cin, output S, output Cout);
	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	logic carry_add, overlap, low_bit;

	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	xor xor0(low_bit, A, B);
	and and0(carry_add, A, B);
	xor xor1(S, low_bit, Cin);
	and and1(overlap, low_bit, Cin);
	or or0(Cout, overlap, carry_add);	
endmodule
