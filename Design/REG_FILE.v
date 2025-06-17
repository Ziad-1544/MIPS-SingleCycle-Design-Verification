module RegFile(input clk, RegWrite, RetAdd, input [4:0] ReadReg1, ReadReg2, WriteReg , input [31:0] WriteData , Next_pc, output reg [31:0] ReadData1, ReadData2 );
    
    //Register File 
    reg [31:0] r_mem [0:31];
    
    //Read Operation 
    always @(*) begin
        ReadData1 = r_mem [ReadReg1];
        ReadData2 = r_mem [ReadReg2];
    end

    //Write Operation 
    always @(negedge clk) begin
        if (RegWrite) begin
            if (RetAdd)  r_mem[31] = Next_pc;
            else  begin
                if (WriteReg != 0) r_mem[WriteReg] = WriteData; //$zero is read-only
            end        
        end
    end

endmodule