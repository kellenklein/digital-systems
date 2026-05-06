module func_mux4_tb();

  reg [3:0] stim;		// bits 2:0 provide stimulus to DUT

  wire F;				// hooked to output of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  func_mux4 iDUT(.A(stim[2]), .B(stim[1]), .C(stim[0]), .F(F));
  
  initial begin
    $display(" A  B  C  F");
	$display("------------");
    for (stim=4'b0000; stim<4'b1000; stim=stim+4'b0001) begin
	  #1;
	  $display(" %b  %b  %b  %b",stim[2],stim[1],stim[0],F);
	end
	$stop();
  end
  
endmodule