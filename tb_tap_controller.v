`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// Design Name: tap_controller
// Module Name: tb_tap_controller.v
// Project Name: JTAG_BoundaryScan_ISim_simple
// Description: Test don gian Reset, DR, IR va Pause/Resume.
////////////////////////////////////////////////////////////////////////////////

module tb_tap_controller;

    // Inputs
    reg tck;
    reg tms;
    reg trst_n;

    // Outputs
    wire capture_dr, shift_dr, update_dr;
    wire capture_ir, shift_ir, update_ir;
    wire test_logic_reset;

    // Instantiate the Unit Under Test (UUT)
    tap_controller uut (
        .tck(tck),
        .tms(tms),
        .trst_n(trst_n),
        .capture_dr(capture_dr),
        .shift_dr(shift_dr),
        .update_dr(update_dr),
        .capture_ir(capture_ir),
        .shift_ir(shift_ir),
        .update_ir(update_ir),
        .test_logic_reset(test_logic_reset)
    );

    initial begin
        tck = 0;
        forever #10 tck = ~tck;
    end

    initial begin
        // Initialize Inputs: reset bang TRST_n.
        tms = 1;
        trst_n = 0;
        #25;
        trst_n = 1;

        // Moi #20 tuong ung mot chu ky TCK.
        // Trang thai trong chu thich dat duoc tai canh len ke tiep.
        tms = 0; #20; // Reset -> Idle

        // BUOC 1: Nhanh DR, co Pause va tiep tuc Shift.
        tms = 1; #20; // Idle -> Select-DR
        tms = 0; #20; // Capture-DR: capture_dr = 1
        tms = 0; #20; // Shift-DR: shift_dr = 1
        tms = 0; #40; // Giu Shift-DR them 2 chu ky
        tms = 1; #20; // Exit1-DR
        tms = 0; #20; // Pause-DR: cac co DR deu bang 0
        tms = 0; #40; // Giu Pause-DR them 2 chu ky
        tms = 1; #20; // Exit2-DR
        tms = 0; #20; // Tiep tuc Shift-DR: shift_dr = 1
        tms = 1; #20; // Exit1-DR
        tms = 1; #20; // Update-DR: update_dr = 1
        tms = 0; #20; // Idle

        // BUOC 2: Nhanh IR, co Pause va tiep tuc Shift.
        tms = 1; #20; // Select-DR
        tms = 1; #20; // Select-IR
        tms = 0; #20; // Capture-IR: capture_ir = 1
        tms = 0; #20; // Shift-IR: shift_ir = 1
        tms = 0; #40; // Giu Shift-IR them 2 chu ky
        tms = 1; #20; // Exit1-IR
        tms = 0; #20; // Pause-IR: cac co IR deu bang 0
        tms = 0; #40; // Giu Pause-IR them 2 chu ky
        tms = 1; #20; // Exit2-IR
        tms = 0; #20; // Tiep tuc Shift-IR: shift_ir = 1
        tms = 1; #20; // Exit1-IR
        tms = 1; #20; // Update-IR: update_ir = 1
        tms = 0; #20; // Idle

        // BUOC 3: Reset bang TMS tu trang thai Shift-DR.
        tms = 1; #20; // Select-DR
        tms = 0; #20; // Capture-DR
        tms = 0; #20; // Shift-DR
        tms = 1; #100; // 5 chu ky TCK: test_logic_reset = 1
        tms = 0; #20; // Tro ve Idle

        // BUOC 4: Reset bat dong bo tu Shift-IR.
        tms = 1; #20; // Select-DR
        tms = 1; #20; // Select-IR
        tms = 0; #20; // Capture-IR
        tms = 0; #20; // Shift-IR
        trst_n = 0; #20; // Reset ngay, khong cho canh TCK
        trst_n = 1; #20; // TMS=0: ve Idle tai canh len
        #40;

        $finish;
    end

endmodule
