/////////////////////////////////////////////////////////
// rise_edge_detect.sv:  This design implements a     //
// circuit that interfaces to a PB swtich and        //
// gives a 1 clk wide puse on a rise of the signal. //
//                                                 //
// Student 1 Name: << Enter you name here >>      //
// Student 2 Name: << Enter name if applicable >>//
//////////////////////////////////////////////////
module rise_edge_detect(
  input clk,      // hook to CLK of flops
  input rst_n,      // hook to PRN
  input sig,      // signal we are detecting a rising edge on
  output sig_rise   // high for 1 clock cycle on rise of sig
);

  //////////////////////////////////////////
  // Declare any needed internal signals //
  ////////////////////////////////////////
  logic sig_ff1,sig_ff2,sig_ff3;
  
  
  ///////////////////////////////////////////////////////
  // Instantiate flops to synchronize and edge detect //
  /////////////////////////////////////////////////////
  d_ff FF1(.clk(clk), .D(sig), .CLRN(1'b1), .PRN(rst_n), .Q(sig_ff1));
  d_ff FF2(.clk(clk), .D(sig_ff1), .CLRN(1'b1), .PRN(rst_n), .Q(sig_ff2));
  d_ff FF3(.clk(clk), .D(sig_ff2), .CLRN(1'b1), .PRN(rst_n), .Q(sig_ff3));
  
  
  //////////////////////////////////////////////////////////
  // Infer any needed logic (data flow) to form sig_rise //
  ////////////////////////////////////////////////////////
    assign sig_rise = sig_ff2 & ~sig_ff3; 
  
endmodule