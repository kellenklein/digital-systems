module ALU_tb();

  //////////////////////////////////
  // Define stimulus of type reg //
  ////////////////////////////////
  reg [7:0] A,B;
  reg [1:0] mode;
  reg error;	// set if an error occurred during testing
  
  ////////////////////////////////////////////////////
  // Signals hooked to DUT output are of type wire //
  //////////////////////////////////////////////////
  wire [7:0] result;
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  ALU iDUT(.A(A), .B(B), .mode(mode), .Y(result));
  
  initial begin
    error = 0;		// innocent till proven guilty
	
	$display("Performing mode 00 testing");
    mode = 2'b00;	// start testing subtraction
	A = 8'hAA;
	B = 8'h56;
	#1;
	if (result!==8'hAB) begin
	  $display("ERR: 0xAA/2 + 0x56 should result in 0xAB.  Your answer was %h",result);
	  error = 1;
	end
	
	A = 8'h5A;
	B = 8'hDB;
	#1;
	if (result!==8'h08) begin
	  $display("ERR:0x5A/2 + 0xDB should result in 0x08 (overflow).  Your answer was %h",result);
	  error = 1;
	end
	
	if (!error)
	  $display("Good...you passed mode 00 moving to mode 01 next");
	  
	mode = 2'b01;
	B = 8'h6E;
	#1;
	if (result!==8'hEC) begin
	  $display("ERR: 0x5A - 0x6E should result in 0xEC.  Your answer was %h",result);
	  error = 1;
	end
	  
	mode = 2'b01;
	A = 8'h9D;
	#1;
	if (result!==8'h2F) begin
	  $display("ERR: 0x9D - 0x6E should result in 0x2F.  Your answer was %h",result);
	  error = 1;
	end	else
	  $display("Good...you passed mode 01 moving to mode 10 next");
	  
	mode = 2'b10;
	A = 8'h95;
	#1;
	if (result!==8'h4A) begin
	  $display("ERR: 0x95 >> 1 should result in 0x4A.  Your answer was %h",result);
	  error = 1;
	end	
	
	A = 8'h4A;
	#1;
	if (result!==8'h25) begin
	  $display("ERR: 0x4A >> 1 should result in 0x25.  Your answer was %h",result);
	  error = 1;
	end

	if (!error)
	  $display("Good...you passed mode 10 moving to mode 11 next");
	  
	mode = 2'b11;
	A = 8'h9C;
	#1;
	if (result!==8'h38) begin
	  $display("ERR: 0x9C << 1 should result in 0x38.  Your answer was %h",result);
	  error = 1;
	end	
	A = 8'h79;
	#1;
	if (result!==8'hF2) begin
	  $display("ERR: 0x79 << 1 should result in 0xF2.  Your answer was %h",result);
	  error = 1;
	end	

    if (!error)
      $display("YAHOO!! test passed");
    
    $stop();
	
  end
  
endmodule
