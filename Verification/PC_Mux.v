module PC_Mux(input [31:0] BranchPC, JumpPC, RS , // For jump register 
                input JumpReg,Jump ,output reg [31:0] FinalNextPC );

        always @(*) begin
            case ({JumpReg,Jump})
                2'b00: FinalNextPC = BranchPC;
                2'b01: FinalNextPC = JumpPC ;
                2'b10,2'b11: FinalNextPC = RS;
            endcase
        end
    
endmodule