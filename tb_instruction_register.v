`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// Design Name: instruction_register
// Module Name: tb_instruction_register.v
// Project Name: JTAG_BoundaryScan_ISim_simple
// Description: Test fixture don gian de quan sat waveform.
////////////////////////////////////////////////////////////////////////////////

module tb_instruction_register;

    // Inputs
    reg tck, trst_n, test_logic_reset;
    reg capture_ir, shift_ir, update_ir, tdi;

    // Outputs
    wire tdo;
    wire [2:0] instruction;

    // Instantiate the Unit Under Test (UUT)
    instruction_register #(.IR_WIDTH(3)) uut(
        .tck(tck),.trst_n(trst_n),.test_logic_reset(test_logic_reset),
        .capture_ir(capture_ir),.shift_ir(shift_ir),.update_ir(update_ir),
        .tdi(tdi),.tdo(tdo),.instruction(instruction));

    initial begin
        tck=0;
        forever #10 tck=~tck;
    end

    initial begin
        // Initialize Inputs
        trst_n=0; test_logic_reset=0;
        capture_ir=0; shift_ir=0; update_ir=0; tdi=0;
        #25; trst_n=1; // instruction = 111 (BYPASS)

        // Capture nap 001 vao thanh ghi dich.
        capture_ir=1;
        #20; capture_ir=0;

        // Nap INTEST = 100, dich bit thap truoc: 0, 0, 1.
        shift_ir=1; tdi=0;
        #20; tdi=0;
        #20; tdi=1;
        #20; shift_ir=0;

        // instruction doi tu 111 sang 100 tai canh xuong.
        update_ir=1;
        #20; update_ir=0;
        #40;

        // Reset TAP dua instruction ve 111.
        test_logic_reset=1;
        #20; test_logic_reset=0;
        #40;
        $finish;
    end

endmodule
