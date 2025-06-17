module JumpBlock(input [31:0] Next_pc , input [31:0] Instruction, output [31:0] OutPC);
    wire [27:0] ShiftedJumpVal;

    assign ShiftedJumpVal = Instruction [25:0] << 2;
    assign OutPC = {Next_pc[31:28],ShiftedJumpVal};
endmodule