`timescale 1ns / 1ps
module boundary_scan_cell (
    input wire tck, trst_n, capture_dr, shift_dr, update_dr,
    input wire serial_in, parallel_in,
    output wire serial_out, parallel_out
);
    reg shift_ff, update_ff;
    assign serial_out=shift_ff;
    assign parallel_out=update_ff;
    always @(posedge tck or negedge trst_n)
        if (!trst_n) shift_ff <= 1'b0;
        else if (capture_dr) shift_ff <= parallel_in;
        else if (shift_dr) shift_ff <= serial_in;
    always @(negedge tck or negedge trst_n)
        if (!trst_n) update_ff <= 1'b0;
        else if (update_dr) update_ff <= shift_ff;
endmodule
