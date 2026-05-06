`timescale 1ns/1ps
module clkdivN #(parameter int WIDTH = 16)(
  input  logic       clk,
  input  logic       rst_n,
  input  logic [1:0] speed_sel,
  output logic       tick
);
  logic [WIDTH-1:0] cnt, nxt_cnt;
  logic [WIDTH-1:0] term;
  logic             at_term;

  function automatic [WIDTH-1:0] pow2m1 (input int k);
    pow2m1 = ( (1 << k) - 1 );
  endfunction

  assign term = (speed_sel==3'b000) ? pow2m1(12)  :
                (speed_sel==3'b001) ? pow2m1(10)  :
                (speed_sel==3'b010) ? pow2m1(8) :
                                      pow2m1(6);

  assign at_term = (cnt == term);
  assign tick  = at_term;
  assign nxt_cnt = at_term ? '0 : (cnt + {{(WIDTH-1){1'b0}},1'b1});

  genvar i;
  generate
    for (i=0; i<WIDTH; i++) begin : g_cnt
      d_en_ff u_cnt_bit (.clk(clk), .rst_n(rst_n), .en(1'b1), .d(nxt_cnt[i]), .q(cnt[i]));
    end
  endgenerate
endmodule
