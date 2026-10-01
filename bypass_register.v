`timescale 1ns / 1ps
module bypass_register (
    input wire tck, trst_n, capture_dr, shift_dr, tdi,
    output wire tdo
);
    reg bypass_bit;
    assign tdo=bypass_bit;
    always @(posedge tck or negedge trst_n)
        if (!trst_n) bypass_bit <= 1'b0;
        else if (capture_dr) bypass_bit <= 1'b0;
        else if (shift_dr) bypass_bit <= tdi;
endmodule
