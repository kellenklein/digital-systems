module d_ff(
  input clk,
  input D,
  input CLRN,
  input PRN,
  output reg Q
);
  always_ff @(posedge clk, negedge CLRN, negedge PRN)
    if (!CLRN)
      Q <= 1'b0;
    else if (!PRN)
      Q <= 1'b1;
    else
      Q <= D;
endmodule
