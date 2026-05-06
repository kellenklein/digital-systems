module cmp1bit_tb();

  reg [2:0] ABstim;		// provides stimulus for {A,B}
  reg [2:0] CMPstim;	// provides stimulus for {AgtBi,AeqBi,AltBi}
  reg [2:0] expected;	// hold expected result from DUT
  reg error;
  
  wire [2:0] result;	// connects to 3-bits of DUT output
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  cmp1bit iDUT(.A(ABstim[1]), .B(ABstim[0]), .AgtBi(CMPstim[2]), .AeqBi(CMPstim[1]), .AltBi(CMPstim[0]),
               .AgtBo(result[2]), .AeqBo(result[1]), .AltBo(result[0]));
  
  initial begin
    error = 1'b0;		// innocent till proven guilty
    for (ABstim=3'b000; ABstim<3'b100; ABstim++) begin
	  CMPstim = 3'b001;
	  while (|CMPstim) begin
	    #5;
	    if (result!==expected) begin
	      $display("ERR: at time %t result not as expected",$time);
		  error = 1'b1;
	    end
		CMPstim = {CMPstim[1:0],1'b0};
	  end
	end
	if (!error)
	  $display("YAHOO!! test of cmp1bit passed!");
	$stop();
  end
  
  always_comb begin
    case ({ABstim,CMPstim})
     5'b000001: expected = 3'b001;
     5'b000010: expected = 3'b010;
     5'b000100: expected = 3'b100;
     5'b001001: expected = 3'b001;
     5'b001010: expected = 3'b001;
     5'b001100: expected = 3'b001;
     5'b010001: expected = 3'b100;
     5'b010010: expected = 3'b100;
     5'b010100: expected = 3'b100;
     5'b011001: expected = 3'b001;
     5'b011010: expected = 3'b010;
     5'b011100: expected = 3'b100;
	endcase
  end
  
endmodule;