`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// Design Name: bypass_register
// Module Name: tb_bypass_register.v
// Project Name: JTAG_BoundaryScan_ISim_simple
// Description: Test fixture don gian de quan sat waveform.
////////////////////////////////////////////////////////////////////////////////

module tb_bypass_register;

    // Inputs
    reg tck, trst_n, capture_dr, shift_dr, tdi;

    // Outputs
    wire tdo;

    // Instantiate the Unit Under Test (UUT)
    bypass_register uut(.tck(tck),.trst_n(trst_n),
        .capture_dr(capture_dr),.shift_dr(shift_dr),.tdi(tdi),.tdo(tdo));

    initial begin
        tck=0;
        forever #10 tck=~tck;
    end

    initial begin
        // Initialize Inputs
        trst_n=0; capture_dr=0; shift_dr=0; tdi=0;
        #25; trst_n=1;

        // Capture dua bit bypass ve 0.
        capture_dr=1;
        #20; capture_dr=0;

        // Dich 1, 0, 1: tdo nhan moi bit tai canh len TCK.
        shift_dr=1; tdi=1;
        #20; tdi=0;
        #20; tdi=1;
        #20; shift_dr=0;

        // Ngung dich: tdo giu 1 du tdi doi ve 0.
        tdi=0;
        #40;
        capture_dr=1;
        #20; capture_dr=0; // tdo = 0
        #40;
        $finish;
    end

endmodule
