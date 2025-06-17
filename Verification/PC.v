module PC(input clk, rst, input [31:0] Next_pc,output reg [31:0] Current_pc);

    always @(posedge clk or posedge rst) begin
        if (rst)  Current_pc <=0;
        else  Current_pc<=Next_pc;
    end

endmodule