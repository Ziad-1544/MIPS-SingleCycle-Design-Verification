module ALUCtrl(input [2:0] ALUOp , input [31:0] Instruction, output reg [3:0] ALUCtrlLines);
    always @(*) begin
        case (ALUOp)
            3'b000: ALUCtrlLines = 4'b0000; // ADD (0)
            3'b001: ALUCtrlLines = 4'b0001; // SUB (1)
            3'b010: begin // R-FORMAT
                        case (Instruction[5:0])
                            6'b000000: ALUCtrlLines = 4'b0111; //SLL (7)
                            6'b000010: ALUCtrlLines = 4'b1000; //SRL (8)
                            6'b000011: ALUCtrlLines = 4'b1001; //SRA (9)
                            
                            //Already Found By the CTRL Unit
                            6'b100000: ALUCtrlLines = 4'b0000; // ADD (0)
                            6'b100010: ALUCtrlLines = 4'b0001; // SUB (1)
                            6'b100100: ALUCtrlLines = 4'b0011; // AND (3)
                            6'b100101: ALUCtrlLines = 4'b0100; // OR (4)
                            6'b100110: ALUCtrlLines = 4'b0101; // XOR (5)

                            6'b100111: ALUCtrlLines = 4'b1011; //NOR (11)
                            6'b101010: ALUCtrlLines = 4'b1100; //SLT (12)
                        endcase
                    end 
            3'b011: ALUCtrlLines = 4'b0011; // AND (3)
            3'b100: ALUCtrlLines = 4'b0100; // OR (4)
            3'b101: ALUCtrlLines = 4'b0101; // XOR (5)
            3'b110: ALUCtrlLines = 4'b0110; // SHIFT 16 LEFT (6)
            3'b111: ALUCtrlLines = 4'b1100; //SLT (12)
        endcase
    end
endmodule