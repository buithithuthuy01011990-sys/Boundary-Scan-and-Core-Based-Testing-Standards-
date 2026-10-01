`timescale 1ns / 1ps
module jtag_top (
    input wire tck,
    input wire tms,
    input wire tdi,
    input wire trst_n,
    input wire [3:0] a,
    input wire [3:0] b,
    input wire sel,

    output wire [3:0] y,
    output wire [2:0] instruction,
    output wire extest_mode,
    output wire intest_mode,
    output wire capture_ir,
    output wire shift_ir,
    output wire update_ir,
    output wire capture_dr,
    output wire shift_dr,
    output wire update_dr,
    output wire test_logic_reset,
    output wire tdo
);
    // 3-bit instruction register: separate SAMPLE, PRELOAD and INTEST.
    localparam [2:0] EXTEST=3'b000, SAMPLE=3'b001, PRELOAD=3'b010,
                     INTEST=3'b100, BYPASS=3'b111;
    tap_controller U_TAP(
        .tck(tck),.tms(tms),.trst_n(trst_n),
        .capture_dr(capture_dr),.shift_dr(shift_dr),.update_dr(update_dr),
        .capture_ir(capture_ir),.shift_ir(shift_ir),.update_ir(update_ir),
        .test_logic_reset(test_logic_reset));
    wire ir_tdo;
    instruction_register #(.IR_WIDTH(3),.BYPASS_INSTR(BYPASS)) U_IR(
        .tck(tck),.trst_n(trst_n),.test_logic_reset(test_logic_reset),
        .capture_ir(capture_ir),.shift_ir(shift_ir),.update_ir(update_ir),
        .tdi(tdi),.tdo(ir_tdo),.instruction(instruction));

    // Instruction decoder. Reserved opcodes fall back to BYPASS.
    assign extest_mode=(instruction==EXTEST);
    assign intest_mode=(instruction==INTEST);
    wire bsr_selected=extest_mode || intest_mode ||
                      (instruction==SAMPLE) || (instruction==PRELOAD);
    wire bypass_selected=!bsr_selected;
    wire bypass_tdo,bsr_tdo;
    bypass_register U_BYPASS(
        .tck(tck),.trst_n(trst_n),
        .capture_dr(capture_dr && bypass_selected),
        .shift_dr(shift_dr && bypass_selected),.tdi(tdi),.tdo(bypass_tdo));

    // [12:9]=Y, [8]=SEL, [7:4]=B, [3:0]=A. LSB first.
    // INTEST observes actual core inputs/response; other BSR modes observe pins.
    wire [12:0] scan_update;
    wire [8:0] core_input;
    wire [3:0] core_y;
    wire [12:0] scan_capture=intest_mode ? {core_y,core_input} : {y,sel,b,a};
    boundary_scan_register #(.WIDTH(13)) U_BSR(
        .tck(tck),.trst_n(trst_n),
        .capture_dr(capture_dr && bsr_selected),
        .shift_dr(shift_dr && bsr_selected),
        .update_dr(update_dr && bsr_selected),
        .tdi(tdi),.parallel_in(scan_capture),.tdo(bsr_tdo),.parallel_out(scan_update));
    boundary_wrapper U_WRAPPER(
        .functional_a(a),.functional_b(b),.functional_sel(sel),
        .test_input(scan_update[8:0]),.test_mode(intest_mode),
        .core_y(core_y),.core_input(core_input));
    // EXTEST drives pins from BSR, independent of the core's arithmetic result.
    // INTEST clamps external outputs to zero while the core is under test.
    assign y=extest_mode ? scan_update[12:9] : intest_mode ? 4'b0 : core_y;
    wire selected_dr_tdo=bsr_selected ? bsr_tdo : bypass_tdo;
    reg tdo_data,tdo_enable;
    always @(negedge tck or negedge trst_n)
        if (!trst_n) begin tdo_data<=1'b0; tdo_enable<=1'b0; end
        else begin
            tdo_enable<=shift_ir || shift_dr;
            tdo_data<=shift_ir ? ir_tdo : selected_dr_tdo;
        end
    assign tdo=tdo_enable ? tdo_data : 1'bz;
endmodule
