`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// Design Name: boundary_scan_cell
// Module Name: tb_boundary_scan_cell.v
// Project Name: JTAG_BoundaryScan_ISim_simple
// Description: Test fixture don gian de quan sat waveform.
////////////////////////////////////////////////////////////////////////////////

module tb_boundary_scan_cell;

    // Inputs
    reg tck, trst_n, capture_dr, shift_dr, update_dr;
    reg serial_in, parallel_in;

    // Outputs
    wire serial_out, parallel_out;

    // Instantiate the Unit Under Test (UUT)
    boundary_scan_cell uut (
        .tck(tck), .trst_n(trst_n),
        .capture_dr(capture_dr), .shift_dr(shift_dr), .update_dr(update_dr),
        .serial_in(serial_in), .parallel_in(parallel_in),
        .serial_out(serial_out), .parallel_out(parallel_out)
    );

    initial begin
        tck=0;
        forever #10 tck=~tck;
    end

    initial begin
        // Initialize Inputs
        trst_n=0; capture_dr=0; shift_dr=0; update_dr=0;
        serial_in=0; parallel_in=0;
        #25; trst_n=1;

        // Capture 1: serial_out = 1, parallel_out van bang 0.
        parallel_in=1; capture_dr=1;
        #20; capture_dr=0;

        // Update: parallel_out = 1 tai canh xuong TCK.
        update_dr=1;
        #20; update_dr=0;

        // Shift 0, 1, 0; parallel_out van giu 1.
        shift_dr=1; serial_in=0;
        #20; serial_in=1;
        #20; serial_in=0;
        #20; shift_dr=0;

        // Update gia tri 0 vua dich vao.
        update_dr=1;
        #20; update_dr=0;
        #40;
        $finish;
    end

endmodule
