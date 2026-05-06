module func_3LUTs_tb();

  reg [5:0] stim;		// bits 4:0 provide stimulus to DUT

  wire F;				// hooked to output of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  func_3LUTs iDUT(.A(stim[4]), .B(stim[3]), .C(stim[2]), .D(stim[1]), .E(stim[0]), .F(F));
  
  initial begin
    $display(" A  B  C  D  E | F ");
	$display("---------------|---");
    for (stim=6'b0000; stim<6'b100000; stim=stim+6'b000001) begin
	  #1;
	  $display(" %b  %b  %b  %b  %b | %b",stim[4],stim[3],stim[2],stim[1],stim[0],F);
	end
	$stop();
  end
  
endmodule