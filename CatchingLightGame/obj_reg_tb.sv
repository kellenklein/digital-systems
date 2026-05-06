`timescale 1ns/1ps

module obj_reg_tb;

    logic clk;
    logic rst_n;
    logic obj_ld;
    logic [17:0] sw_in;
    logic [17:0] obj_mask;

    // DUT
    obj_reg dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .obj_ld   (obj_ld),
        .sw_in    (sw_in),
        .obj_mask (obj_mask)
    );

    // Clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("=== obj_reg Testbench ===");

        // Initial signals
        rst_n  = 1'b0;   // assert reset (active-low)
        obj_ld = 1'b0;
        sw_in  = 18'h00000;

        // Hold reset for a couple of cycles
        repeat (2) @(posedge clk);
        rst_n = 1'b1;    // release reset

        @(posedge clk);  // let things settle

        $display("[%0t] After reset: obj_mask = %h", $time, obj_mask);
        if (obj_mask !== 18'h00000) begin
            $fatal(1, "ERROR: obj_mask should be 0 after reset!");
        end

        // ------------------------------------------------------------
        // Load first pattern
        // ------------------------------------------------------------
        sw_in  = 18'h00020;   // bit 5
        obj_ld = 1'b1;
        @(posedge clk);
        obj_ld = 1'b0;        // deassert load

        @(posedge clk);       // wait one cycle

        $display("[%0t] After first load: obj_mask = %h (expected %h)",
                 $time, obj_mask, sw_in);

        if (obj_mask !== 18'h00020) begin
            $fatal(1, "ERROR: obj_mask failed to load first pattern!");
        end

        // ------------------------------------------------------------
        // Hold value when obj_ld = 0
        // ------------------------------------------------------------
        sw_in = 18'h20000;    // change sw_in, but obj_ld = 0
        repeat (2) @(posedge clk);

        $display("[%0t] Hold test: obj_mask = %h (should still be 00020)",
                 $time, obj_mask);

        if (obj_mask !== 18'h00020) begin
            $fatal(1, "ERROR: obj_mask changed when obj_ld=0 (should hold)!");
        end

        // ------------------------------------------------------------
        // Load second pattern
        // ------------------------------------------------------------
        sw_in  = 18'h00004;   // bit 2
        obj_ld = 1'b1;
        @(posedge clk);
        obj_ld = 1'b0;

        @(posedge clk);

        $display("[%0t] After second load: obj_mask = %h (expected %h)",
                 $time, obj_mask, sw_in);

        if (obj_mask !== 18'h00004) begin
            $fatal(1, "ERROR: obj_mask failed to load second pattern!");
        end

        $display("Yahoo! obj_reg testbench PASSED!");
        $stop;
    end

endmodule
