`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// Design Name: boundary_wrapper
// Module Name: tb_boundary_wrapper.v
// Project Name: JTAG_BoundaryScan_ISim_simple
// Description: Test fixture don gian de quan sat waveform.
////////////////////////////////////////////////////////////////////////////////

module tb_boundary_wrapper;

    // Inputs
    reg [3:0] functional_a, functional_b;
    reg functional_sel, test_mode;
    reg [8:0] test_input;

    // Outputs
    wire [3:0] core_y;
    wire [8:0] core_input;

    // Instantiate the Unit Under Test (UUT)
    boundary_wrapper uut(.functional_a(functional_a),.functional_b(functional_b),
        .functional_sel(functional_sel),.test_input(test_input),.test_mode(test_mode),
        .core_y(core_y),.core_input(core_input));

    initial begin
        // Initialize Inputs
        functional_a=0; functional_b=0; functional_sel=0;
        test_input=0; test_mode=0;
        #100;

        // Che do chuc nang: 3 + 2 = 5.
        functional_a=3; functional_b=2; functional_sel=0;
        #50;
        // Chuyen sang XOR: 3 XOR 2 = 1.
        functional_sel=1;
        #50;

        // Che do test: 5 + 3 = 8.
        test_mode=1;
        test_input={1'b0,4'd3,4'd5};
        #50;
        // Doi dau vao chuc nang nhung core_y van bang 8.
        functional_a=0; functional_b=0;
        #50;
        // Test XOR: 5 XOR 3 = 6.
        test_input={1'b1,4'd3,4'd5};
        #50;
        // Tro ve chuc nang: 0 XOR 0 = 0.
        test_mode=0;
        #50;
        $finish;
    end

endmodule
