module PC_ADDER(input [31:0] Current_pc,output [31:0] Next_pc);

    assign Next_pc = Current_pc + 4;

endmodule