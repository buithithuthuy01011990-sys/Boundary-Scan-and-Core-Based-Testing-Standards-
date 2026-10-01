`timescale 1ns / 1ps
// Educational core-access wrapper; not a complete IEEE 1500 wrapper.
// Scan storage belongs to the shared BSR in jtag_top.
module boundary_wrapper (
    input wire [3:0] functional_a, functional_b,
    input wire functional_sel,
    input wire [8:0] test_input,
    input wire test_mode,
    output wire [3:0] core_y,
    output wire [8:0] core_input
);
    wire [3:0] selected_a=test_mode ? test_input[3:0] : functional_a;
    wire [3:0] selected_b=test_mode ? test_input[7:4] : functional_b;
    wire selected_sel=test_mode ? test_input[8] : functional_sel;
    assign core_input={selected_sel,selected_b,selected_a};
    ip_core U_CORE(.a(selected_a),.b(selected_b),.sel(selected_sel),.y(core_y));
endmodule
