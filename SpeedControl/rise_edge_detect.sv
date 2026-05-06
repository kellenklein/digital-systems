/////////////////////////////////////////////////////////
// rise_edge_detect.sv:  This design implements a     //
// circuit that interfaces to a PB swtich and  	     //
// gives a 1 clk wide puse on a rise of the signal. //
//                                                 //
// Student 1 Name: << Kellen Klein >>             //
// Student 2 Name: << Evan Williams >>           //
//////////////////////////////////////////////////
module rise_edge_detect(
  input clk,			// hook to CLK of flops
  input rst_n,			// hook to PRN
  input sig,			// signal we are detecting a rising edge on
  output sig_rise		// high for 1 clock cycle on rise of sig
);

	//////////////////////////////////////////
	// Declare any needed internal signals //
	////////////////////////////////////////
  logic [2:0] ff_q;
	
	///////////////////////////////////////////////////////
	// Instantiate flops to synchronize and edge detect //
	/////////////////////////////////////////////////////
  d_ff d_ff0(.clk(clk), .D(sig), .CLRN(1'b1), .PRN(rst_n), .Q(ff_q[0]));
  d_ff d_ff1(.clk(clk), .D(ff_q[0]), .CLRN(1'b1), .PRN(rst_n), .Q(ff_q[1]));
  d_ff d_ff2(.clk(clk), .D(ff_q[1]), .CLRN(1'b1), .PRN(rst_n), .Q(ff_q[2]));
	
  
	//////////////////////////////////////////////////////////
	// Infer any needed logic (data flow) to form sig_rise //
	////////////////////////////////////////////////////////
  assign sig_rise = (~ff_q[2]) & ff_q[1];
 
	
endmodule
