`timescale 1ns/1ps

module hit_detector_tb;

    logic [17:0] window_mask;
    logic [17:0] obj_mask;
    logic        hit;

    hit_detector dut (
        .window_mask(window_mask),
        .obj_mask   (obj_mask),
        .hit        (hit)
    );

    initial begin
        $display("window_mask     obj_mask        hit");

        window_mask = 18'h00100; obj_mask = 18'h00100;
        #1 $display("%b   %b   %b", window_mask, obj_mask, hit);

        window_mask = 18'h00100; obj_mask = 18'h00080;
        #1 $display("%b   %b   %b", window_mask, obj_mask, hit);

        window_mask = 18'h00002; obj_mask = 18'h00002;
        #1 $display("%b   %b   %b", window_mask, obj_mask, hit);

        $finish;
    end

endmodule
