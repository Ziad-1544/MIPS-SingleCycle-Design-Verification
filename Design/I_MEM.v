module I_mem(input [31:0] Current_pc, output [31:0] Instruction);

  reg [7:0] mem [0:2**32-1]; Can't be simulated 
   
  
  
   //Big Endian
   assign Instruction [31:24] = i_mem [Current_pc];
   assign Instruction [23:16] = i_mem [Current_pc+1];
   assign Instruction [15:8 ] = i_mem [Current_pc+2];
   assign Instruction [ 7:0 ] = i_mem [Current_pc+3];

endmodule