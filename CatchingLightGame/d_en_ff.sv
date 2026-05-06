`timescale 1ns/1ps
module d_en_ff (
  input  logic clk,
  input  logic rst_n,
  input  logic en,
  input  logic d,
  output logic q
);
  logic q_fb, d_mux;
  assign q_fb  = q;
  assign d_mux = en ? d : q_fb;

  d_ff u_ff (
    .clk(clk),
    .D(d_mux),
    .Q(q),
    .CLRN(rst_n),
    .PRN(1'b1)
  );
endmodule
