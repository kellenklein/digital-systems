// note that this is NOT a program - it is a hardware description that gets turned into logic!

module segFdec
(
	input [3:0] D,
	output segF
);

/// You figure out implementation as instances of verilog primitive gates ///
//reg [0:15] truth_table = 16'b0111_0001_00xx_xxxx; 
//assign segF = truth_table[D];
// (~D3)(~D2)(D0) + (D1)(D0) + (~D2)(D1)
logic term0, term1, term2;
and and0(term0, ~D[3], ~D[2], D[0]);
and and1(term1, D[1], D[0]);
and and2(term2, ~D[2], D[1]);
or or0(segF, term0, term1, term2);
//assign segF = (~D[3] & ~D[2] & D[0]) | (D[1] & D[0]) | (~D[2] & D[1]);

endmodule
