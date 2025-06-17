vlib work
vlog -f src_files.list +define+SIM +cover=bces -covercells
vsim -voptargs=+acc work.MIPS_TB
add wave -position insertpoint  \
sim:/MIPS_TB/rst \
sim:/MIPS_TB/clk \
sim:/MIPS_TB/DUT/PC_INS/Current_pc \
sim:/MIPS_TB/DUT/I_mem_INS/i_mem \
sim:/MIPS_TB/DUT/D_MEM_INS/d_mem \
sim:/MIPS_TB/DUT/RegFile_INS/r_mem \
sim:/MIPS_TB/DUT/PC_Mux_INS/BranchPC \
sim:/MIPS_TB/DUT/PC_Mux_INS/FinalNextPC \
sim:/MIPS_TB/DUT/PC_INS/Next_pc \
sim:/MIPS_TB/DUT/PC_INS/Current_pc \
sim:/MIPS_TB/DUT/BranchBlock_INS/Zero \
sim:/MIPS_TB/DUT/BranchBlock_INS/ShiftedBranchVal \
sim:/MIPS_TB/DUT/BranchBlock_INS/Next_pc \
sim:/MIPS_TB/DUT/BranchBlock_INS/CtrSig \
sim:/MIPS_TB/DUT/BranchBlock_INS/BranchVal \
sim:/MIPS_TB/DUT/BranchBlock_INS/BranchedPC \
sim:/MIPS_TB/DUT/BranchBlock_INS/OutPC \
sim:/MIPS_TB/DUT/BranchBlock_INS/BNE \
sim:/MIPS_TB/DUT/BranchBlock_INS/BEQ \
sim:/MIPS_TB/DUT/ALU_INS/Zero \
sim:/MIPS_TB/DUT/ALU_INS/ShiftAmt \
sim:/MIPS_TB/DUT/ALU_INS/OP2 \
sim:/MIPS_TB/DUT/ALU_INS/OP1 \
sim:/MIPS_TB/DUT/ALU_INS/Instruction \
sim:/MIPS_TB/DUT/ALU_INS/ALUResult \
sim:/MIPS_TB/DUT/ALU_INS/ALUCtrlLines \
sim:/MIPS_TB/DUT/MemtoReg \
sim:/MIPS_TB/DUT/D_MEM_INS/ReadData \
sim:/MIPS_TB/DUT/RegFile_INS/WriteData \
sim:/MIPS_TB/DUT/RegFile_INS/WriteReg \
sim:/MIPS_TB/DUT/RegFile_INS/WriteData \
sim:/MIPS_TB/DUT/RegFile_INS/RetAdd \
sim:/MIPS_TB/DUT/RegFile_INS/RegWrite \
sim:/MIPS_TB/DUT/RegFile_INS/ReadReg2 \
sim:/MIPS_TB/DUT/RegFile_INS/ReadReg1 \
sim:/MIPS_TB/DUT/RegFile_INS/ReadData2 \
sim:/MIPS_TB/DUT/RegFile_INS/ReadData1 \
sim:/MIPS_TB/check_sra_instruction/temp \
sim:/MIPS_TB/check_sra_instruction/shamt \
sim:/MIPS_TB/check_sra_instruction/rt \
sim:/MIPS_TB/check_sra_instruction/rd \
sim:/MIPS_TB/check_sra_instruction/instr \
sim:/MIPS_TB/check_sra_instruction/expected_result

run -all