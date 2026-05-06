//-----------------------------------------------------------------------------
// hit.sv   
//-----------------------------------------------------------------------------

module hit_detector (
    input  logic [17:0] window_mask,
    input  logic [17:0] obj_mask,
    output logic        hit
);


    assign hit = |(window_mask & obj_mask);
    //TODO: Complete the combinational logic.
    // hit = 1 if ANY overlapping bit is 1
    

endmodule
