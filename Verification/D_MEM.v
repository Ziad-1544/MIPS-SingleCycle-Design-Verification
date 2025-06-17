module D_MEM(input MemWrite, MemRead, input [1:0] SigSize, input [31:0] WriteData, input [31:0] ADD, output reg [31:0] ReadData);
    
    // reg [7:0] d_mem [0:2**32-1]; Can't be simulated 
    reg [7:0] d_mem [0:1023]; // For simulation Purpose

    //D_MEM LITTLE ENDIAN
    //Write Operation
    always @(*) begin
        if(MemWrite)begin
            case (SigSize)
                2'b00: begin
                            d_mem [ADD]   = WriteData [7:0];
                        end 
                2'b01: begin
                            d_mem [ADD]   = WriteData [7:0 ];
                            d_mem [ADD+1] = WriteData [15:8];
                        end 
                default:begin
                            d_mem [ADD]   = WriteData [ 7:0 ]; 
                            d_mem [ADD+1] = WriteData [15:8 ];
                            d_mem [ADD+2] = WriteData [23:16];
                            d_mem [ADD+3] = WriteData [31:24];
                        end 
            endcase
        end
    end

    //Read Operation
    always @(*) begin
        if (MemRead) begin
            case (SigSize)
                2'b00: begin
                    ReadData [ 7:0 ] = d_mem [ADD];
                    ReadData [15:8 ] = 0;
                    ReadData [23:16] = 0;
                    ReadData [31:24] = 0; 
                end
                2'b01: begin
                    ReadData [ 7:0 ] = d_mem [ADD];
                    ReadData [15:8 ] = d_mem [ADD+1];
                    ReadData [23:16] = 0;
                    ReadData [31:24] = 0;
                end
                default: begin
                    ReadData [ 7:0 ] = d_mem [ADD]; 
                    ReadData [15:8 ] = d_mem [ADD+1];
                    ReadData [23:16] = d_mem [ADD+2];
                    ReadData [31:24] = d_mem [ADD+3];
                end 
            endcase 
        end
        else ReadData = 0;
    end
endmodule