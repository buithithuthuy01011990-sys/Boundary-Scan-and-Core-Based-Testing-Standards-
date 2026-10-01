`timescale 1ns / 1ps
module boundary_scan_register #(parameter WIDTH=13)(
    input wire tck, trst_n, capture_dr, shift_dr, update_dr, tdi,
    input wire [WIDTH-1:0] parallel_in,
    output wire tdo,
    output wire [WIDTH-1:0] parallel_out
);
    wire [WIDTH:0] chain;
    assign chain[WIDTH]=tdi;
    assign tdo=chain[0];
    genvar i;
    generate for (i=0;i<WIDTH;i=i+1) begin : cells
        boundary_scan_cell U_CELL (
            .tck(tck),.trst_n(trst_n),.capture_dr(capture_dr),
            .shift_dr(shift_dr),.update_dr(update_dr),
            .serial_in(chain[i+1]),.parallel_in(parallel_in[i]),
            .serial_out(chain[i]),.parallel_out(parallel_out[i])
        );
    end endgenerate
endmodule
