module BranchBlock(input [31:0] Next_pc ,input [31:0] BranchVal,input BEQ, BNE, Zero, output [31:0] OutPC);
    
    wire [31:0] ShiftedBranchVal,BranchedPC;
    wire CtrSig;

    assign ShiftedBranchVal = BranchVal << 2 ;
    assign BranchedPC = ShiftedBranchVal + Next_pc;

    //Mux Control Handling
    assign CtrSig = (BEQ & Zero) | (BNE & ~Zero);

    //Output Mux 
    assign OutPC = CtrSig ? BranchedPC : Next_pc ;
    
endmodule