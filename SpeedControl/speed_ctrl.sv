module speed_ctrl (
  input  logic       clk,
  input  logic       rst_n,
  input  logic       speed_up,
  input  logic       speed_down,
  output logic [1:0] speed_sel
);

  //Difine internal signals if needed
  logic en;
  logic [1:0] nxt;


  // --- Register enable ---
  //TODO 1: en is 1 only when exactly one button is pressed 
  xor xor_enable(en, speed_up, speed_down);



  // --- Compute next-state logic , dataflow only---
  //TODO 2: increment if speed_up==1, else decrement
  assign  nxt     =  (speed_up) ? speed_sel[1:0] + 2'b01 : speed_sel[1:0] - 2'b01;

  // --- C. Register update ---
  //TODO 3: instantiate two d_en_ff to store speed_sel[1:0]
  d_en_ff d_en_ff0(.clk(clk), .rst_n(rst_n), .en(en), .d(nxt[0]), .q(speed_sel[0]));
  d_en_ff d_en_ff1(.clk(clk), .rst_n(rst_n), .en(en), .d(nxt[1]), .q(speed_sel[1]));


endmodule
