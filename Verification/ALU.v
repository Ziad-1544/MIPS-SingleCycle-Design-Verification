module ALU(input [31:0] OP1, OP2, input [3:0] ALUCtrlLines, input [31:0] Instruction ,output reg [31:0] ALUResult ,output Zero );
    wire [4:0] ShiftAmt;

    assign ShiftAmt = Instruction [10:6];
    assign Zero     = (ALUResult == 0)? 1 : 0 ; 

    always @(*) begin
        case (ALUCtrlLines)
            4'b0000: ALUResult = OP1 + OP2;                                     // ADD (0)
            4'b0001: ALUResult = OP1 - OP2;                                     // SUB (1)
        
            4'b0011: ALUResult = OP1 & OP2;                                     // AND (3)
            4'b0100: ALUResult = OP1 | OP2;                                     // OR (4)
            4'b0101: ALUResult = OP1 ^ OP2;                                     // XOR (5)
            4'b0110: ALUResult = OP2 << 16;                                     // SHIFT 16 LEFT (6)
            4'b0111: ALUResult = OP2 << ShiftAmt ;                              // SLL (Shift amount 5 bits) (7)
            4'b1000: ALUResult = OP2 >> ShiftAmt ;                              // SRL (Shift amount 5 bits) (8)
            4'b1001: ALUResult = $signed(OP2) >>> ShiftAmt ;                    // SRA (Shift amount 5 bits) (9)

            4'b1011: ALUResult = ~(OP1 | OP2)    ;                              // NOR (11)
            4'b1100: ALUResult = ($signed(OP1) < $signed(OP2))? 'b1 : 0 ;       // SLT (12)
            default: ALUResult = 0               ;                              // NOP
        endcase
    end
    
endmodule