`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// Design Name: boundary_scan_register
// Module Name: tb_boundary_scan_register.v
// Project Name: JTAG_BoundaryScan_ISim_simple
// Description: Test fixture don gian de quan sat waveform.
////////////////////////////////////////////////////////////////////////////////

module tb_boundary_scan_register;

    // Inputs
    reg tck, trst_n, capture_dr, shift_dr, update_dr, tdi;
    reg [12:0] parallel_in;

    // Outputs
    wire tdo;
    wire [12:0] parallel_out;

    // Instantiate the Unit Under Test (UUT)
    boundary_scan_register #(.WIDTH(13)) uut(.tck(tck),.trst_n(trst_n),
        .capture_dr(capture_dr),.shift_dr(shift_dr),.update_dr(update_dr),
        .tdi(tdi),.parallel_in(parallel_in),.tdo(tdo),.parallel_out(parallel_out));

    initial begin
        tck=0;
        forever #10 tck=~tck;
    end

    initial begin
        // Initialize Inputs
        trst_n=0; capture_dr=0; shift_dr=0; update_dr=0;
        tdi=0; parallel_in=0;
        #25; trst_n=1;

        // Capture mau song song 13'h1A55.
        parallel_in=13'h1A55; capture_dr=1;
        #20; capture_dr=0;
        update_dr=1;
        #20; update_dr=0; // parallel_out = 13'h1A55

        // Dich mau 13'h0005, LSB truoc: 1,0,1,0,0,0,0,0,0,0,0,0,0.
        // Trong khi dich, parallel_out van giu 13'h1A55.
        shift_dr=1; tdi=1;
        #20; tdi=0;
        #20; tdi=1;
        #20; tdi=0;
        #20; tdi=0;
        #20; tdi=0;
        #20; tdi=0;
        #20; tdi=0;
        #20; tdi=0;
        #20; tdi=0;
        #20; tdi=0;
        #20; tdi=0;
        #20; tdi=0;
        #20; shift_dr=0;

        update_dr=1;
        #20; update_dr=0; // parallel_out = 13'h0005
        #40;
        $finish;
    end

endmodule
