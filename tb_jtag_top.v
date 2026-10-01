`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Design Name: jtag_top
// Module Name: tb_jtag_top.v
// Description: Reset -> BYPASS -> SAMPLE -> PRELOAD -> EXTEST -> INTEST
// PRELOAD is the preparation step for EXTEST.
////////////////////////////////////////////////////////////////////////////////
module tb_jtag_top;

    // Signals arranged in the requested waveform order.
    wire [3:0] y;

    wire [2:0] instruction;
    wire extest_mode;
    wire intest_mode;

    wire capture_ir;
    wire shift_ir;
    wire update_ir;

    wire capture_dr;
    wire shift_dr;
    wire update_dr;

    wire test_logic_reset;

    wire tdo;
    reg tdi;
    reg tck;
    reg tms;
    reg trst_n;

    reg [3:0] a;
    reg [3:0] b;
    reg sel;

    // Instantiate the Unit Under Test: all 19 ports connected.
    jtag_top uut (
        .tck(tck),
        .tms(tms),
        .tdi(tdi),
        .trst_n(trst_n),
        .a(a),
        .b(b),
        .sel(sel),
        .y(y),
        .instruction(instruction),
        .extest_mode(extest_mode),
        .intest_mode(intest_mode),
        .capture_ir(capture_ir),
        .shift_ir(shift_ir),
        .update_ir(update_ir),
        .capture_dr(capture_dr),
        .shift_dr(shift_dr),
        .update_dr(update_dr),
        .test_logic_reset(test_logic_reset),
        .tdo(tdo)
    );

    initial begin
        tck=0;
        forever #10 tck=~tck;
    end

    initial begin
        // 1. RESET
        tdi=0; tms=1; trst_n=0;
        a=3; b=2; sel=0; // Functional Y=5
        #25; trst_n=1;
        #100; // TMS=1 trong 5 chu ky TCK.
        tms=0; tdi=0; #20; // Reset -> Idle
        
        // 2. BYPASS = 111
        tms=1; tdi=0; #20; // Select-DR
        tms=1; tdi=0; #20; // Select-IR
        tms=0; tdi=0; #20; // Capture-IR
        tms=0; tdi=0; #20; // Shift-IR
        tms=0; tdi=1; #20; // IR bit 0, LSB truoc
        tms=0; tdi=1; #20; // IR bit 1, LSB truoc
        tms=1; tdi=1; #20; // IR bit 2, LSB truoc
        tms=1; tdi=0; #20; // Update-IR
        tms=0; tdi=0; #20; // Idle
        
        // Gui B6; TDO tra ve 6C: tre mot bit, Capture nap 0.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=0; #20; // DR bit 0, LSB truoc
        tms=0; tdi=1; #20; // DR bit 1, LSB truoc
        tms=0; tdi=1; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=1; #20; // DR bit 4, LSB truoc
        tms=0; tdi=1; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=1; tdi=1; #20; // DR bit 7, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        
        // 3. SAMPLE = 001: quan sat A=3, B=2, SEL=0, Y=5.
        tms=1; tdi=0; #20; // Select-DR
        tms=1; tdi=0; #20; // Select-IR
        tms=0; tdi=0; #20; // Capture-IR
        tms=0; tdi=0; #20; // Shift-IR
        tms=0; tdi=1; #20; // IR bit 0, LSB truoc
        tms=0; tdi=0; #20; // IR bit 1, LSB truoc
        tms=1; tdi=0; #20; // IR bit 2, LSB truoc
        tms=1; tdi=0; #20; // Update-IR
        tms=0; tdi=0; #20; // Idle
        
        // Capture {5,0,2,3}=13'h0A23; Y van bang 5 khi scan.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=0; #20; // DR bit 0, LSB truoc
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=0; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=0; #20; // DR bit 4, LSB truoc
        tms=0; tdi=0; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=0; #20; // DR bit 9, LSB truoc
        tms=0; tdi=0; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=0; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        
        // 4. PRELOAD = 010: nap san mau cho EXTEST va INTEST.
        tms=1; tdi=0; #20; // Select-DR
        tms=1; tdi=0; #20; // Select-IR
        tms=0; tdi=0; #20; // Capture-IR
        tms=0; tdi=0; #20; // Shift-IR
        tms=0; tdi=0; #20; // IR bit 0, LSB truoc
        tms=0; tdi=1; #20; // IR bit 1, LSB truoc
        tms=1; tdi=0; #20; // IR bit 2, LSB truoc
        tms=1; tdi=0; #20; // Update-IR
        tms=0; tdi=0; #20; // Idle
        
        // Nap {Y=10, SEL=0, B=3, A=5}=1435. Chan Y van bang 5.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=1; #20; // DR bit 0, LSB truoc
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=1; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=1; #20; // DR bit 4, LSB truoc
        tms=0; tdi=1; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=0; #20; // DR bit 9, LSB truoc
        tms=0; tdi=1; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=1; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        
        // 5. EXTEST = 000: extest_mode=1, chan Y=10 tu BSR.
        tms=1; tdi=0; #20; // Select-DR
        tms=1; tdi=0; #20; // Select-IR
        tms=0; tdi=0; #20; // Capture-IR
        tms=0; tdi=0; #20; // Shift-IR
        tms=0; tdi=0; #20; // IR bit 0, LSB truoc
        tms=0; tdi=0; #20; // IR bit 1, LSB truoc
        tms=1; tdi=0; #20; // IR bit 2, LSB truoc
        tms=1; tdi=0; #20; // Update-IR
        tms=0; tdi=0; #20; // Idle
        
        // Capture {Y=10,SEL=0,B=2,A=3}=1423; nap lai mau 1435.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=1; #20; // DR bit 0, LSB truoc
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=1; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=1; #20; // DR bit 4, LSB truoc
        tms=0; tdi=1; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=0; #20; // DR bit 9, LSB truoc
        tms=0; tdi=1; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=1; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        
        // 6. INTEST = 100: intest_mode=1; chan Y=0 de cach ly.
        tms=1; tdi=0; #20; // Select-DR
        tms=1; tdi=0; #20; // Select-IR
        tms=0; tdi=0; #20; // Capture-IR
        tms=0; tdi=0; #20; // Shift-IR
        tms=0; tdi=0; #20; // IR bit 0, LSB truoc
        tms=0; tdi=0; #20; // IR bit 1, LSB truoc
        tms=1; tdi=1; #20; // IR bit 2, LSB truoc
        tms=1; tdi=0; #20; // Update-IR
        tms=0; tdi=0; #20; // Idle
        // BSR cap Acore=5, Bcore=3, SELcore=0 cho core; ket qua=8.
        // Doi dau vao ngoai thanh 1/1, core van dung mau test 5/3.
        a=1; b=1;
        
        // Capture dap ung core {8,0,3,5}=1035, doc qua TDO.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=1; #20; // DR bit 0, LSB truoc
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=1; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=1; #20; // DR bit 4, LSB truoc
        tms=0; tdi=1; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=0; #20; // DR bit 9, LSB truoc
        tms=0; tdi=1; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=1; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        // TDO theo thu tu: 1,0,1,0,1,1,0,0,0,0,0,0,1.
        #40;
        $finish;
    end
endmodule
