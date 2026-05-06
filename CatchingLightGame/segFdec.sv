// segFdec.sv
module segFdec
(
    input  [3:0] D,
    output reg   segF
);

always @(*) begin
    case (D)
        // segment F ON (active-low = 0)
        4'h0,
        4'h4,
        4'h5,
        4'h6,
        4'h8,
        4'h9: segF = 1'b0;

        // segment F OFF (active-low = 1)
        4'h1,
        4'h2,
        4'h3,
        4'h7: segF = 1'b1;

        // for anything > 9, turn it off safely
        default: segF = 1'b1;
    endcase
end

endmodule
