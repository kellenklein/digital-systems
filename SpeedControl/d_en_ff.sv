////////////////////////////////////////////////////////
// d_en_ff.sv: Models a FF with active high enable   //
//                                                  //
// Student 1 Name: << Kellen Klein >>              //
// Student 2 Name: << Evan Williams >>            //
///////////////////////////////////////////////////
module d_en_ff(
  input  logic clk,
  input  logic rst_n,
  input  logic en,
  input  logic d,
  output logic q
);

  ////////////////////////////////////////////////////
  // Declare any needed internal sigals below here //
  //////////////////////////////////////////////////
  logic D_mux;
  
  ///////////////////////////////////////////////////
  // Infer logic needed to feed d input of simple //
  // flop to form an enabled flop (use dataflow) //
  ////////////////////////////////////////////////
  assign D_mux = (en) ? d : q;
  
  //////////////////////////////////////////////
  // Instantiate simple d_ff without enable  //
  // and tie PRN inactive.  Connect d input //    
  // to logic you inferred above.          //
  //////////////////////////////////////////
  d_ff d_ff0(.clk(clk), .D(D_mux), .CLRN(rst_n), .PRN(1'b1), .Q(q));
 
endmodule
