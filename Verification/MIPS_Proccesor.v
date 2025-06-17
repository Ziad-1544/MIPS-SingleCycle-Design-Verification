module MIPS_Proccesor(input clk, rst);
    //PC WIRES
    wire [31:0] FinalNextPC, Next_pc, Current_pc; 
    wire [31:0] BranchPC, JumpPC;

    //Instruction
    wire [31:0] Instruction;
    
    //Control Signals
    wire RegDst, RetAdd, Jump, JumpReg, BEQ, BNE, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ExtType;
    wire [1:0] SigSize;
    wire [2:0] ALUOp;

    //Immediate Extension
    wire [31:0] ExtImmediateVal;

    //ALU Control Unit 
    wire [3:0] ALUCtrlLines;

    //ALU
    wire [31:0] ALUOutput,OP2;
    wire Zero;

    //Data Memory 
    wire [31:0] ReadData;

    //MEM-REG DATA
    wire [31:0] WriteData;

    //Register File
    wire [31:0] ReadData1, ReadData2;
    wire [4:0] WriteReg;

    //Instantiations
    PC PC_INS (clk, rst, FinalNextPC, Current_pc);

    PC_ADDER PC_ADDER_INS (Current_pc, Next_pc);

    assign WriteReg = RegDst? Instruction[15:11] : Instruction [20:16] ;

    RegFile RegFile_INS (clk, RegWrite, RetAdd, Instruction[25:21], Instruction [20:16], WriteReg , WriteData , Next_pc, ReadData1, ReadData2 );

    ImedExt ImedExt_INS (Instruction [15:0] , ExtType, ExtImmediateVal);
    
    BranchBlock BranchBlock_INS (Next_pc , ExtImmediateVal, BEQ, BNE, Zero, BranchPC);

    JumpBlock JumpBlock_INS (Next_pc , Instruction, JumpPC);

    PC_Mux PC_Mux_INS (BranchPC, JumpPC, ReadData1 , JumpReg, Jump ,FinalNextPC );

    I_mem I_mem_INS (Current_pc, Instruction);

    CTRL_UNIT CTRL_UNIT_INS (Instruction, RegDst, RetAdd, Jump, JumpReg, BEQ, BNE, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ExtType, SigSize, ALUOp);

    ALUCtrl ALUCtrl_INS (ALUOp , Instruction, ALUCtrlLines);

    assign OP2 = ALUSrc? ExtImmediateVal : ReadData2;

    ALU ALU_INS (ReadData1, OP2, ALUCtrlLines, Instruction ,ALUOutput , Zero);
    
    D_MEM D_MEM_INS (MemWrite, MemRead, SigSize, ReadData2, ALUOutput , ReadData);
    
    assign WriteData = MemtoReg? ReadData : ALUOutput;
    
endmodule