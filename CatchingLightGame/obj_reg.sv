//-----------------------------------------------------------------------------
// obj_reg.sv 
//-----------------------------------------------------------------------------
// Stores the selected object.
//
// Behavior:
//   - On reset:        obj_mask = 0
//   - On obj_ld = 1:   obj_mask = sw_in
//   - Otherwise:       hold previous value
//
// Implement using:
//   - simple combinational logic for next_obj_mask
//   - a vector of d_en_ff to store obj_mask
//
// No always_ff is allowed here; use the provided d_en_ff flip-flops.
//-----------------------------------------------------------------------------

module obj_reg (
    input  logic        clk,
    input  logic        rst_n,     // async active-low reset
    input  logic        obj_ld,    // load enable
    input  logic [17:0] sw_in,
    output logic [17:0] obj_mask
);

    logic [17:0] next_obj_mask;

    // TODO: combinational assignment for next_obj_mask
    // It should select between sw_in and obj_mask based on obj_ld.
    //
    // Example pattern:
    // assign next_obj_mask = ( ... ) ? ( ... ) : ( ... );
    assign next_obj_mask = (obj_ld) ? sw_in : obj_mask;

    // TODO: instantiate a vector of d_en_ff[17:0]
    d_en_ff obj_mask_ff[17:0](.clk(clk), .rst_n(rst_n), .en(obj_ld), .d(next_obj_mask), .q(obj_mask));
    
endmodule
