////////////////////////////////////////////////////////
// RCA32.sv  This design will add two 32-bit vectors //
// plus a carry in to produce a sum and a carry out //
/////////////////////////////////////////////////////
module RCA32(input [31:0] A, input [31:0] B, input Cin, output [31:0] S, output	Cout);
	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	wire [30:0] Carries;	// this is driven by .Cout of FA and will
							// in a "promoted" form drive .Cin of FA's
	
	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	//<< You fill in vectored instantiation of 32 FA cells >>
	FA fa[31:0](.A(A), .B(B), .Cin({Carries[30:0], Cin}), .S(S), .Cout({Cout, Carries[30:0]}));
	//<< Also remember a line to drive Cout of top level with Carries[31] >>
	// I didn't do the above because I just placed in-place concats for the Cout and Cin
endmodule
