module CTRL_UNIT(input [31:0] Instruction, output reg RegDst, RetAdd, Jump, JumpReg, BEQ, BNE, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ExtType, output reg [1:0] SigSize, output reg [2:0] ALUOp);
  //Flags:
  reg R_format, I_format, J_format;

  //Flags Handling   
    always @(*) begin
      case (Instruction[31:26])
        6'b000000: begin // R-format : 0
          R_format = 1;
          I_format = 0;
          J_format = 0;
        end

        6'b000010,6'b000011: begin // J-format (j) : 2 & (jal) : 3
          R_format = 0;
          I_format = 0;
          J_format = 1;
        end

        default: begin
          R_format = 0;
          I_format = 1;
          J_format = 0;
        end
      endcase

    end

    //Ctrl Signals Logic 
    always @(*) begin
        RegDst      = 0;
        RetAdd      = 0;
        Jump        = 0;
        BEQ         = 0;
        BNE         = 0;
        MemRead     = 0;
        MemtoReg    = 0;
        MemWrite    = 0;
        ALUSrc      = 0;
        RegWrite    = 0;
        ExtType     = 0;
        JumpReg     = 0;
        SigSize     = 2'b11 ;
        ALUOp       = 3'b0  ;

        if (R_format) begin
            if (Instruction [5:0] == 6'b001000 ) begin
                JumpReg = 1'b1 ; 
            end
            else begin
                RegWrite = 1'b1   ;
                RegDst   = 1'b1   ;
                ALUOp    = 3'b010 ;
            end
        end
        else if (I_format) begin
            ALUSrc = 1'b1 ;
            //RegDst is [20:16] by default
            case (Instruction [31:26])
                6'b000100: begin //BEQ
                                BEQ         = 1'b1    ;
                                ALUOp       = 3'b001  ;
                                ALUSrc      = 1'b0    ;
                            end
                6'b000101: begin //BNE
                                BNE         = 1'b1    ;
                                ALUOp       = 3'b001  ;
                                ALUSrc      = 1'b0    ;
                            end
                6'b001000: begin //ADDI
                                RegWrite    = 1'b1    ;
                                ALUOp       = 3'b000  ;
                            end
                6'b001010: begin //SLTI
                                RegWrite    = 1'b1    ;
                                ALUOp       = 3'b111  ;
                            end
                6'b001100: begin //ANDI
                                RegWrite    = 1'b1    ;
                                ALUOp       = 3'b011  ;      
                                ExtType     = 1'b1    ;      
                            end
                6'b001101: begin //ORI
                                RegWrite    = 1'b1    ;
                                ALUOp       = 3'b100  ; 
                                ExtType     = 1'b1    ;      
                            end
                6'b001110: begin //XORI
                                RegWrite    = 1'b1    ;
                                ALUOp       = 3'b101  ; 
                                ExtType     = 1'b1    ;      
                            end
                6'b001111: begin //LUI
                                RegWrite    = 1'b1    ;
                                ALUOp       = 3'b110  ;
                            end
                6'b100000: begin //LB
                                RegWrite    = 1'b1    ;
                                ALUOp       = 3'b000  ;
                                MemRead     = 1'b1    ;
                                MemtoReg    = 1'b1    ;
                                SigSize     = 2'b0    ;
                             end
                6'b100001: begin //LH 
                                RegWrite    = 1'b1    ;
                                ALUOp       = 3'b000  ;
                                MemRead     = 1'b1    ;
                                MemtoReg    = 1'b1    ;
                                SigSize     = 2'b01   ;
                             end
                6'b100011: begin //LW
                                RegWrite    = 1'b1    ;
                                ALUOp       = 3'b000  ;
                                MemRead     = 1'b1    ;
                                MemtoReg    = 1'b1    ;
                                SigSize     = 2'b10   ;
                             end
                6'b101000: begin //SB 
                                ALUOp       = 3'b000  ;
                                MemWrite    = 1'b1    ;
                                SigSize     = 2'b0    ;
                            end
                6'b101001: begin //SH
                                ALUOp       = 3'b000  ;
                                MemWrite    = 1'b1    ;
                                SigSize     = 2'b01   ;
                            end
                6'b101011: begin //SW
                                ALUOp       = 3'b000  ;
                                MemWrite    = 1'b1    ;
                                SigSize     = 2'b10   ;
                            end
            endcase
        end
        else begin
             Jump = 1'b1;
             if (Instruction[31:26] == 6'b000011) begin // JAL Handling
                RegWrite = 1'b1 ;
                RetAdd   = 1'b1 ;
             end 
        end
    end

endmodule