`timescale 1ns / 1ps
module instruction_register #(
    parameter IR_WIDTH=3,
    parameter [IR_WIDTH-1:0] BYPASS_INSTR={IR_WIDTH{1'b1}}
)(
    input wire tck, trst_n, test_logic_reset,
    input wire capture_ir, shift_ir, update_ir, tdi,
    output wire tdo,
    output reg [IR_WIDTH-1:0] instruction
);
    // IR_WIDTH must be at least 2. Capture-IR always ends in binary 01.
    reg [IR_WIDTH-1:0] shift_reg;
    assign tdo=shift_reg[0];
    always @(posedge tck or negedge trst_n)
        if (!trst_n) shift_reg <= {{(IR_WIDTH-2){1'b0}},2'b01};
        else if (test_logic_reset || capture_ir)
            shift_reg <= {{(IR_WIDTH-2){1'b0}},2'b01};
        else if (shift_ir) shift_reg <= {tdi,shift_reg[IR_WIDTH-1:1]};
    always @(negedge tck or negedge trst_n)
        if (!trst_n) instruction <= BYPASS_INSTR;
        else if (test_logic_reset) instruction <= BYPASS_INSTR;
        else if (update_ir) instruction <= shift_reg;
endmodule
