module ImedExt(input [15:0] ImmediateVal, input ExtType, output [31:0] ExtImmediateVal);

assign ExtImmediateVal = ExtType ? {16'b0, ImmediateVal} : {{16{ImmediateVal[15]}}, ImmediateVal};
    
endmodule