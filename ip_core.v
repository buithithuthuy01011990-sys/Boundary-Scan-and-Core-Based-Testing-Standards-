`timescale 1ns / 1ps
module ip_core (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       sel,
    output reg  [3:0] y
);
    always @(*) begin
        case (sel)
            1'b0: y = a + b;
            1'b1: y = a ^ b;
            default: y = 4'b0000;
        endcase
    end
endmodule
