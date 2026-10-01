`timescale 1ns / 1ps
module tap_controller (
    input  wire tck,
    input  wire tms,
    input  wire trst_n,
    output reg  capture_dr,
    output reg  shift_dr,
    output reg  update_dr,
    output reg  capture_ir,
    output reg  shift_ir,
    output reg  update_ir,
    output wire test_logic_reset
);
    localparam TEST_LOGIC_RESET = 4'd0,
               RUN_TEST_IDLE    = 4'd1,
               SELECT_DR_SCAN   = 4'd2,
               CAPTURE_DR       = 4'd3,
               SHIFT_DR         = 4'd4,
               EXIT1_DR         = 4'd5,
               PAUSE_DR         = 4'd6,
               EXIT2_DR         = 4'd7,
               UPDATE_DR        = 4'd8,
               SELECT_IR_SCAN   = 4'd9,
               CAPTURE_IR       = 4'd10,
               SHIFT_IR         = 4'd11,
               EXIT1_IR         = 4'd12,
               PAUSE_IR         = 4'd13,
               EXIT2_IR         = 4'd14,
               UPDATE_IR        = 4'd15;

    reg [3:0] state, next_state;

    assign test_logic_reset = (state == TEST_LOGIC_RESET);

    always @(posedge tck or negedge trst_n) begin
        if (!trst_n)
            state <= TEST_LOGIC_RESET;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            TEST_LOGIC_RESET: next_state = tms ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
            RUN_TEST_IDLE:    next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
            SELECT_DR_SCAN:   next_state = tms ? SELECT_IR_SCAN   : CAPTURE_DR;
            CAPTURE_DR:       next_state = tms ? EXIT1_DR         : SHIFT_DR;
            SHIFT_DR:         next_state = tms ? EXIT1_DR         : SHIFT_DR;
            EXIT1_DR:         next_state = tms ? UPDATE_DR        : PAUSE_DR;
            PAUSE_DR:         next_state = tms ? EXIT2_DR         : PAUSE_DR;
            EXIT2_DR:         next_state = tms ? UPDATE_DR        : SHIFT_DR;
            UPDATE_DR:        next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
            SELECT_IR_SCAN:   next_state = tms ? TEST_LOGIC_RESET : CAPTURE_IR;
            CAPTURE_IR:       next_state = tms ? EXIT1_IR         : SHIFT_IR;
            SHIFT_IR:         next_state = tms ? EXIT1_IR         : SHIFT_IR;
            EXIT1_IR:         next_state = tms ? UPDATE_IR        : PAUSE_IR;
            PAUSE_IR:         next_state = tms ? EXIT2_IR         : PAUSE_IR;
            EXIT2_IR:         next_state = tms ? UPDATE_IR        : SHIFT_IR;
            UPDATE_IR:        next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
            default:          next_state = TEST_LOGIC_RESET;
        endcase
    end

    always @(*) begin
        capture_dr = 1'b0; shift_dr = 1'b0; update_dr = 1'b0;
        capture_ir = 1'b0; shift_ir = 1'b0; update_ir = 1'b0;
        case (state)
            CAPTURE_DR: capture_dr = 1'b1;
            SHIFT_DR:   shift_dr   = 1'b1;
            UPDATE_DR:  update_dr  = 1'b1;
            CAPTURE_IR: capture_ir = 1'b1;
            SHIFT_IR:   shift_ir   = 1'b1;
            UPDATE_IR:  update_ir  = 1'b1;
        endcase
    end
endmodule
