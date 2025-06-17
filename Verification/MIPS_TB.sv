module MIPS_TB();
    
    //VAR
    logic clk , rst;
    logic R_format,I_format,J_format;
    logic [31:0] Current_pc,Instruction;

    //Instantiation
    MIPS_Proccesor DUT (clk,rst);

    //CLK Generation
    initial begin
        clk=0;
        forever #1 clk = ~clk;
    end

    // Main Test Bench
    initial begin
        Current_pc = 0;
        rst_task(); // rst before the clk starts
        repeat(87)begin
            Instruction [31:24] = DUT.I_mem_INS.i_mem [Current_pc];
            Instruction [23:16] = DUT.I_mem_INS.i_mem [Current_pc+1];
            Instruction [15:8 ] = DUT.I_mem_INS.i_mem [Current_pc+2];
            Instruction [ 7:0 ] = DUT.I_mem_INS.i_mem [Current_pc+3];

            case (Instruction[31:26])
                6'b000000: begin // R-format : 0
                  R_format = 1;
                  I_format = 0;
                  J_format = 0;
                end

                6'b000010: begin // J-format (j) : 2
                  R_format = 0;
                  I_format = 0;
                  J_format = 1;
                end

                6'b000011: begin // J-format (jal) : 3
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

            if (R_format) begin
            case (Instruction[5:0])  // function code for R-format
                6'b100000: check_add_instruction(Instruction);   // ADD
                6'b100010: check_sub_instruction(Instruction);   // SUB
                6'b100100: check_and_instruction(Instruction);   // AND
                6'b100101: check_or_instruction(Instruction);    // OR
                6'b100110: check_xor_instruction(Instruction);   // XOR
                6'b100111: check_nor_instruction(Instruction);   // NOR
                6'b000000: check_sll_instruction(Instruction);   // SLL
                6'b000010: check_srl_instruction(Instruction);   // SRL
                6'b000011: check_sra_instruction(Instruction);   // SRA
                6'b101010: check_slt_instruction(Instruction);   // SLT
                6'b001000: check_jr_instruction(Instruction);    // JR
                default: $display("Unknown R-format instruction, Function: %h", Instruction[5:0]);
            endcase
            // Default PC update for most R-format instructions
            if (Instruction[5:0] != 6'b001000) // Not JR instruction
                Current_pc = Current_pc + 4;
        end
        else if (I_format) begin
            case (Instruction[31:26])  // opcode for I-format
                6'b001000: check_addi_instruction(Instruction);  // ADDI
                6'b001100: check_andi_instruction(Instruction);  // ANDI
                6'b001101: check_ori_instruction(Instruction);   // ORI
                6'b001110: check_xori_instruction(Instruction);  // XORI
                6'b001111: check_lui_instruction(Instruction);   // LUI
                6'b100011: check_lw_instruction(Instruction);    // LW
                6'b101011: check_sw_instruction(Instruction);    // SW
                6'b000100: check_beq_instruction(Instruction);   // BEQ
                6'b000101: check_bne_instruction(Instruction);   // BNE
                6'b001010: check_slti_instruction(Instruction);  // SLTI
                6'b100000: check_lb_instruction(Instruction);    // LB
                6'b100001: check_lh_instruction(Instruction);    // LH
                6'b101000: check_sb_instruction(Instruction);    // SB
                6'b101001: check_sh_instruction(Instruction);    // SH
                default: $display("Unknown I-format instruction, Opcode: %h", Instruction[31:26]);
            endcase
            // PC update done in each task for branch instructions
            if (Instruction[31:26] != 6'b000100 && Instruction[31:26] != 6'b000101)
                Current_pc = Current_pc + 4; // Only for non-branch instructions
        end
        else begin // J-format
            case (Instruction[31:26])
                6'b000010: check_j_instruction(Instruction);     // J
                6'b000011: check_jal_instruction(Instruction);   // JAL
                default: $display("Unknown J-format instruction, Opcode: %h", Instruction[31:26]);
            endcase
            // PC update done inside J-format tasks
        end
            
        end
        $display("ALL Went Well");
        $stop;
    end

    task rst_task;
    integer i;
    
    // Initialize all registers to zero
    for (i = 0; i < 32; i = i + 1) begin
        DUT.RegFile_INS.r_mem[i] = 0;
    end

    rst = 1;
    @(negedge clk);
    
    
    rst = 0;
    endtask

    // R-format instruction checking tasks
    task check_add_instruction(input [31:0] instr);
        logic [4:0] rs, rt, rd;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        rd = instr[15:11];
        
        @(negedge clk); // Check at stable time
        
        expected_result = DUT.RegFile_INS.r_mem[rs] + DUT.RegFile_INS.r_mem[rt];
        if (DUT.RegFile_INS.r_mem[rd] === expected_result)
            $display("ADD instruction PASSED: $%0d = $%0d + $%0d = %0d", rd, rs, rt, expected_result);
        else begin
            $display("ADD instruction FAILED: $%0d = %0d, Expected: %0d", rd, DUT.RegFile_INS.r_mem[rd], expected_result);
            $stop;
        end
    endtask
    
    task check_sub_instruction(input [31:0] instr);
        logic [4:0] rs, rt, rd;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        rd = instr[15:11];
        
        @(negedge clk); // Check at stable time
        
        expected_result = DUT.RegFile_INS.r_mem[rs] - DUT.RegFile_INS.r_mem[rt];
        if (DUT.RegFile_INS.r_mem[rd] === expected_result)
            $display("SUB instruction PASSED: $%0d = $%0d - $%0d = %0d", rd, rs, rt, expected_result);
        else begin
            $display("SUB instruction FAILED: $%0d = %0d, Expected: %0d", rd, DUT.RegFile_INS.r_mem[rd], expected_result);
            $stop;
        end
    endtask
    
    task check_and_instruction(input [31:0] instr);
        logic [4:0] rs, rt, rd;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        rd = instr[15:11];
        
        @(negedge clk); // Check at stable time
        
        expected_result = DUT.RegFile_INS.r_mem[rs] & DUT.RegFile_INS.r_mem[rt];
        if (DUT.RegFile_INS.r_mem[rd] === expected_result)
            $display("AND instruction PASSED: $%0d = $%0d & $%0d = %0d", rd, rs, rt, expected_result);
        else begin
            $display("AND instruction FAILED: $%0d = %0d, Expected: %0d", rd, DUT.RegFile_INS.r_mem[rd], expected_result);
            $stop;
        end
    endtask
    
    task check_or_instruction(input [31:0] instr);
        logic [4:0] rs, rt, rd;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        rd = instr[15:11];
        
        @(negedge clk); // Check at stable time
        
        expected_result = DUT.RegFile_INS.r_mem[rs] | DUT.RegFile_INS.r_mem[rt];
        if (DUT.RegFile_INS.r_mem[rd] === expected_result)
            $display("OR instruction PASSED: $%0d = $%0d | $%0d = %0d", rd, rs, rt, expected_result);
        else begin
            $display("OR instruction FAILED: $%0d = %0d, Expected: %0d", rd, DUT.RegFile_INS.r_mem[rd], expected_result);
            $stop;
        end
    endtask
    
    task check_xor_instruction(input [31:0] instr);
        logic [4:0] rs, rt, rd;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        rd = instr[15:11];
        
        @(negedge clk); // Check at stable time
        
        expected_result = DUT.RegFile_INS.r_mem[rs] ^ DUT.RegFile_INS.r_mem[rt];
        if (DUT.RegFile_INS.r_mem[rd] === expected_result)
            $display("XOR instruction PASSED: $%0d = $%0d ^ $%0d = %0d", rd, rs, rt, expected_result);
        else begin
            $display("XOR instruction FAILED: $%0d = %0d, Expected: %0d", rd, DUT.RegFile_INS.r_mem[rd], expected_result);
            $stop;
        end
    endtask
    
    task check_nor_instruction(input [31:0] instr);
        logic [4:0] rs, rt, rd;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        rd = instr[15:11];
        
        @(negedge clk); // Check at stable time
        
        expected_result = ~(DUT.RegFile_INS.r_mem[rs] | DUT.RegFile_INS.r_mem[rt]);
        if (DUT.RegFile_INS.r_mem[rd] === expected_result)
            $display("NOR instruction PASSED: $%0d = ~($%0d | $%0d) = %0d", rd, rs, rt, expected_result);
        else begin
            $display("NOR instruction FAILED: $%0d = %0d, Expected: %0d", rd, DUT.RegFile_INS.r_mem[rd], expected_result);
            $stop;
        end
    endtask
    
    task check_sll_instruction(input [31:0] instr);
        logic [4:0] rt, rd, shamt;
        logic [31:0] expected_result;
        
        rt = instr[20:16];
        rd = instr[15:11];
        shamt = instr[10:6];
        
        @(negedge clk);
        
        expected_result = DUT.RegFile_INS.r_mem[rt] << shamt;
        if (DUT.RegFile_INS.r_mem[rd] === expected_result)
            $display("SLL instruction PASSED: $%0d = $%0d << %0d = %0d", rd, rt, shamt, expected_result);
        else begin
            $display("SLL instruction FAILED: $%0d = %0d, Expected: %0d", rd, DUT.RegFile_INS.r_mem[rd], expected_result);
            $stop;
        end
    endtask
    
    task check_srl_instruction(input [31:0] instr);
        logic [4:0] rt, rd, shamt;
        logic [31:0] expected_result;
        
        rt = instr[20:16];
        rd = instr[15:11];
        shamt = instr[10:6];
        
        @(negedge clk);
        
        expected_result = DUT.RegFile_INS.r_mem[rt] >> shamt;
        if (DUT.RegFile_INS.r_mem[rd] === expected_result)
            $display("SRL instruction PASSED: $%0d = $%0d >> %0d = %0d", rd, rt, shamt, expected_result);
        else begin
            $display("SRL instruction FAILED: $%0d = %0d, Expected: %0d", rd, DUT.RegFile_INS.r_mem[rd], expected_result);
            $stop;
        end
    endtask
    
    task check_sra_instruction(input [31:0] instr);
        logic [4:0] rt, rd, shamt;
        logic [31:0] expected_result, temp;
        
        rt = instr[20:16];
        rd = instr[15:11];
        shamt = instr[10:6];
        
        @(negedge clk); //Simulation Bug
        
        temp = DUT.RegFile_INS.r_mem[rt];
        expected_result = $signed(temp) >>> shamt;
        if (DUT.RegFile_INS.r_mem[rd] === expected_result)
            $display("SRA instruction PASSED: $%0d = $%0d >>> %0d = %0d", rd, rt, shamt, expected_result);
        else begin
            $display("SRA instruction FAILED: $%0d = %0d, Expected: %0d", rd, DUT.RegFile_INS.r_mem[rd], expected_result);
            $stop;
        end
    endtask
    
    task check_slt_instruction(input [31:0] instr);
        logic [4:0] rs, rt, rd;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        rd = instr[15:11];
        
        @(negedge clk);
        
        expected_result = $signed(DUT.RegFile_INS.r_mem[rs]) < $signed(DUT.RegFile_INS.r_mem[rt]) ? 1 : 0;
        if (DUT.RegFile_INS.r_mem[rd] === expected_result)
            $display("SLT instruction PASSED: $%0d = ($%0d < $%0d) = %0d", rd, rs, rt, expected_result);
        else begin
            
            $display("SLT instruction FAILED: $%0d = %0d, Expected: %0d", rd, DUT.RegFile_INS.r_mem[rd], expected_result);
            $stop;
        end
    endtask
    
    task check_jr_instruction(input [31:0] instr);
        logic [4:0] rs;
        logic [31:0] expected_pc;
        
        rs = instr[25:21];
        
        expected_pc = DUT.RegFile_INS.r_mem[rs];
        
        @(negedge clk);
        Current_pc = expected_pc; // Update current PC in the testbench
        
        if (DUT.PC_INS.Current_pc === expected_pc)
            $display("JR instruction PASSED: PC = $%0d = %0h", rs, expected_pc);
        else begin
            $display("JR instruction FAILED: PC = %0h, Expected: %0h", DUT.PC_INS.Current_pc, expected_pc);
            $stop;
        end
    endtask
    
    // I-format instruction checking tasks
    task check_addi_instruction(input [31:0] instr);
        logic [4:0] rs, rt;
        logic [15:0] imm;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        imm = instr[15:0];
        
        @(negedge clk);
        
        expected_result = DUT.RegFile_INS.r_mem[rs] + $signed(imm);
        if (DUT.RegFile_INS.r_mem[rt] === expected_result)
            $display("ADDI instruction PASSED: $%0d = $%0d + %0d = %0d", rt, rs, $signed(imm), expected_result);
        else begin
            $display("ADDI instruction FAILED: $%0d = %0d, Expected: %0d", rt, DUT.RegFile_INS.r_mem[rt], expected_result);
            $stop;
        end
    endtask
    
    task check_andi_instruction(input [31:0] instr);
        logic [4:0] rs, rt;
        logic [15:0] imm;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        imm = instr[15:0];
        
        @(negedge clk);
        
        expected_result = DUT.RegFile_INS.r_mem[rs] & {16'b0, imm};
        if (DUT.RegFile_INS.r_mem[rt] === expected_result)
            $display("ANDI instruction PASSED: $%0d = $%0d & %0d = %0d", rt, rs, imm, expected_result);
        else begin
            $display("ANDI instruction FAILED: $%0d = %0d, Expected: %0d", rt, DUT.RegFile_INS.r_mem[rt], expected_result);
            $stop;
        end
    endtask
    
    task check_ori_instruction(input [31:0] instr);
        logic [4:0] rs, rt;
        logic [15:0] imm;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        imm = instr[15:0];
        
        @(negedge clk);
        
        expected_result = DUT.RegFile_INS.r_mem[rs] | {16'b0, imm};
        if (DUT.RegFile_INS.r_mem[rt] === expected_result)
            $display("ORI instruction PASSED: $%0d = $%0d | %0d = %0d", rt, rs, imm, expected_result);
        else begin
            $display("ORI instruction FAILED: $%0d = %0d, Expected: %0d", rt, DUT.RegFile_INS.r_mem[rt], expected_result);
            $stop;
        end
    endtask
    
    task check_xori_instruction(input [31:0] instr);
        logic [4:0] rs, rt;
        logic [15:0] imm;
        logic [31:0] expected_result;
        
        rs = instr[25:21];
        rt = instr[20:16];
        imm = instr[15:0];
        
        @(negedge clk);
        
        expected_result = DUT.RegFile_INS.r_mem[rs] ^ {16'b0, imm};
        if (DUT.RegFile_INS.r_mem[rt] === expected_result)
            $display("XORI instruction PASSED: $%0d = $%0d ^ %0d = %0d", rt, rs, imm, expected_result);
        else begin
            $display("XORI instruction FAILED: $%0d = %0d, Expected: %0d", rt, DUT.RegFile_INS.r_mem[rt], expected_result);
            $stop;
        end
    endtask
    
    task check_lui_instruction(input [31:0] instr);
        logic [4:0] rt;
        logic [15:0] imm;
        logic [31:0] expected_result;
        
        rt = instr[20:16];
        imm = instr[15:0];
        
        @(negedge clk);
        
        expected_result = {imm, 16'b0};
        if (DUT.RegFile_INS.r_mem[rt] === expected_result)
            $display("LUI instruction PASSED: $%0d = %0d << 16 = %0d", rt, imm, expected_result);
        else begin
            $display("LUI instruction FAILED: $%0d = %0d, Expected: %0d", rt, DUT.RegFile_INS.r_mem[rt], expected_result);
            $stop;
        end
    endtask
    
    task check_lw_instruction(input [31:0] instr);
        logic [4:0] rs, rt;
        logic [15:0] offset;
        logic [31:0] address, expected_data;
        
        rs = instr[25:21];
        rt = instr[20:16];
        offset = instr[15:0];
        
        @(negedge clk);
        
        address = DUT.RegFile_INS.r_mem[rs] + $signed(offset);
        expected_data = {DUT.D_MEM_INS.d_mem[address+3], DUT.D_MEM_INS.d_mem[address+2], 
                         DUT.D_MEM_INS.d_mem[address+1], DUT.D_MEM_INS.d_mem[address]};
        
        if (DUT.RegFile_INS.r_mem[rt] === expected_data)
            $display("LW instruction PASSED: $%0d = MEM[%0h] = %0h", rt, address, expected_data);
        else begin
            $display("LW instruction FAILED: $%0d = %0h, Expected: %0h", rt, DUT.RegFile_INS.r_mem[rt], expected_data);
            $stop;
        end
    endtask
    
    task check_sw_instruction(input [31:0] instr);
        logic [4:0] rs, rt;
        logic [15:0] offset;
        logic [31:0] address, data_to_store, stored_data;
        
        rs = instr[25:21];
        rt = instr[20:16];
        offset = instr[15:0];
        
        address = DUT.RegFile_INS.r_mem[rs] + $signed(offset);
        data_to_store = DUT.RegFile_INS.r_mem[rt];
        
        @(negedge clk);
        
        stored_data = {DUT.D_MEM_INS.d_mem[address+3], DUT.D_MEM_INS.d_mem[address+2], 
                         DUT.D_MEM_INS.d_mem[address+1], DUT.D_MEM_INS.d_mem[address]};
        
        if (stored_data === data_to_store)
            $display("SW instruction PASSED: MEM[%0h] = $%0d = %0h", address, rt, data_to_store);
        else begin
            $display("SW instruction FAILED: MEM[%0h] = %0h, Expected: %0h", address, stored_data, data_to_store);
            $stop;
        end
    endtask
    
    task check_beq_instruction(input [31:0] instr);
    logic [4:0] rs, rt;
    logic [15:0] imm;
    logic [31:0] old_pc, branch_target;
    logic branch_taken;
    
    rs = instr[25:21];
    rt = instr[20:16];
    imm = instr[15:0];
    old_pc = Current_pc;
    
    branch_taken = (DUT.RegFile_INS.r_mem[rs] === DUT.RegFile_INS.r_mem[rt]);
    branch_target = old_pc + 4 + ($signed(imm) << 2);
    
    @(negedge clk);
    
    if (branch_taken) begin
        Current_pc = branch_target; // Update testbench PC
        if (DUT.PC_INS.Current_pc === branch_target)
            $display("BEQ instruction PASSED: Branch taken to %0d", branch_target);
        else begin
            $display("BEQ instruction FAILED: PC = %0d, Expected: %0d", DUT.PC_INS.Current_pc, branch_target);
            $stop;
        end
    end else begin
        Current_pc = old_pc + 4; // Update testbench PC
        if (DUT.PC_INS.Current_pc === old_pc + 4)
            $display("BEQ instruction PASSED: Branch not taken");
        else begin
            $display("BEQ instruction FAILED: PC = %0d, Expected: %0d", DUT.PC_INS.Current_pc, old_pc + 4);
            $stop;
        end
    end
endtask

task check_bne_instruction(input [31:0] instr);
    logic [4:0] rs, rt;
    logic [15:0] imm;
    logic [31:0] old_pc, branch_target;
    logic branch_taken;
    
    rs = instr[25:21];
    rt = instr[20:16];
    imm = instr[15:0];
    old_pc = Current_pc;
    
    branch_taken = (DUT.RegFile_INS.r_mem[rs] !== DUT.RegFile_INS.r_mem[rt]);
    branch_target = old_pc + 4 + ($signed(imm) << 2);
    
    @(negedge clk);
    
    if (branch_taken) begin
        Current_pc = branch_target; // Update testbench PC
        if (DUT.PC_INS.Current_pc === branch_target)
            $display("BNE instruction PASSED: Branch taken to %0d", branch_target);
        else begin
            $display("BNE instruction FAILED: PC = %0d, Expected: %0d", DUT.PC_INS.Current_pc, branch_target);
            $stop;
        end
        end else begin
        Current_pc = old_pc + 4; // Update testbench PC
        if (DUT.PC_INS.Current_pc === old_pc + 4)
            $display("BNE instruction PASSED: Branch not taken");
        else begin
            $display("BNE instruction FAILED: PC = %0d, Expected: %0d", DUT.PC_INS.Current_pc, old_pc + 4);
            $stop;
        end
        end
endtask

task check_slti_instruction(input [31:0] instr);
    logic [4:0] rs, rt;
    logic [15:0] imm;
    logic [31:0] expected_result;
    
    rs = instr[25:21];
    rt = instr[20:16];
    imm = instr[15:0];
    
    @(negedge clk);
    
    expected_result = $signed(DUT.RegFile_INS.r_mem[rs]) < $signed(imm) ? 1 : 0;
    if (DUT.RegFile_INS.r_mem[rt] === expected_result)
        $display("SLTI instruction PASSED: $%0d = ($%0d < %0d) = %0d", rt, rs, $signed(imm), expected_result);
    else begin
        $display("SLTI instruction FAILED: $%0d = %0d, Expected: %0d", rt, DUT.RegFile_INS.r_mem[rt], expected_result);
        $stop;
    end
endtask

task check_lb_instruction(input [31:0] instr);
    logic [4:0] rs, rt;
    logic [15:0] offset;
    logic [31:0] address;
    logic [7:0] byte_data;
    logic [31:0] expected_data;
    
    rs = instr[25:21];
    rt = instr[20:16];
    offset = instr[15:0];
    
    @(negedge clk);
    
    address = DUT.RegFile_INS.r_mem[rs] + $signed(offset);
    byte_data = DUT.D_MEM_INS.d_mem[address];
    expected_data = {{24{byte_data[7]}}, byte_data}; // Sign extend
    
    if (DUT.RegFile_INS.r_mem[rt] === expected_data)
        $display("LB instruction PASSED: $%0d = MEM[%0h]_byte = %0h", rt, address, expected_data);
    else begin
        $display("LB instruction FAILED: $%0d = %0h, Expected: %0h", rt, DUT.RegFile_INS.r_mem[rt], expected_data);
        $stop;
    end
endtask

task check_lh_instruction(input [31:0] instr);
    logic [4:0] rs, rt;
    logic [15:0] offset;
    logic [31:0] address;
    logic [15:0] half_word;
    logic [15:0] expected_data;
    
    rs = instr[25:21];
    rt = instr[20:16];
    offset = instr[15:0];
    
    @(negedge clk);
    
    address = DUT.RegFile_INS.r_mem[rs] + $signed(offset);
    half_word = {DUT.D_MEM_INS.d_mem[address+1], DUT.D_MEM_INS.d_mem[address]};
    expected_data = {{16{half_word[15]}}, half_word}; // Sign extend
    
    if (DUT.RegFile_INS.r_mem[rt] === expected_data)
        $display("LH instruction PASSED: $%0d = MEM[%0h]_halfword = %0h", rt, address, expected_data);
    else begin
        $display("LH instruction FAILED: $%0d = %0h, Expected: %0h", rt, DUT.RegFile_INS.r_mem[rt], expected_data);
        $stop;
    end
endtask

task check_sb_instruction(input [31:0] instr);
    logic [4:0] rs, rt;
    logic [15:0] offset;
    logic [31:0] address;
    logic [7:0] data_to_store, stored_byte;
    
    rs = instr[25:21];
    rt = instr[20:16];
    offset = instr[15:0];
    
    address = DUT.RegFile_INS.r_mem[rs] + $signed(offset);
    data_to_store = DUT.RegFile_INS.r_mem[rt][7:0];
    
    @(negedge clk);
    
    stored_byte = DUT.D_MEM_INS.d_mem[address];
    
    if (stored_byte === data_to_store)
        $display("SB instruction PASSED: MEM[%0h] = $%0d[7:0] = %0h", address, rt, data_to_store);
    else begin
        $display("SB instruction FAILED: MEM[%0h] = %0h, Expected: %0h", address, stored_byte, data_to_store);
        $stop;
    end
endtask

task check_sh_instruction(input [31:0] instr);
    logic [4:0] rs, rt;
    logic [15:0] offset;
    logic [31:0] address;
    logic [15:0] data_to_store, stored_halfword;
    
    rs = instr[25:21];
    rt = instr[20:16];
    offset = instr[15:0];
    
    address = DUT.RegFile_INS.r_mem[rs] + $signed(offset);
    data_to_store = DUT.RegFile_INS.r_mem[rt][15:0];
    
    @(negedge clk);
    
    stored_halfword = {DUT.D_MEM_INS.d_mem[address+1], DUT.D_MEM_INS.d_mem[address]};
    
    if (stored_halfword === data_to_store)
        $display("SH instruction PASSED: MEM[%0h] = $%0d[15:0] = %0h", address, rt, data_to_store);
    else begin
        $display("SH instruction FAILED: MEM[%0h] = %0h, Expected: %0h", address, stored_halfword, data_to_store);
        $stop;
    end
endtask

task check_j_instruction(input [31:0] instr);
    logic [25:0] target;
    logic [31:0] expected_pc;
    
    target = instr[25:0];
    expected_pc = {Current_pc[31:28], target, 2'b00};
    
    @(negedge clk);
    
    Current_pc = expected_pc; // Update testbench PC
    
    if (DUT.PC_INS.Current_pc === expected_pc)
        $display("J instruction PASSED: PC = %0d", expected_pc);
    else begin
        $display("J instruction FAILED: PC = %0d, Expected: %0d", DUT.PC_INS.Current_pc, expected_pc);
        $stop;
    end
endtask

task check_jal_instruction(input [31:0] instr);
    logic [25:0] target;
    logic [31:0] expected_pc, return_addr;
    
    target = instr[25:0];
    expected_pc = {Current_pc[31:28], target, 2'b00};
    return_addr = Current_pc + 4;
    
    @(negedge clk);
    
    Current_pc = expected_pc; // Update testbench PC
    
    if (DUT.PC_INS.Current_pc === expected_pc && DUT.RegFile_INS.r_mem[31] === return_addr)
        $display("JAL instruction PASSED: PC = %0d, $ra = %0d", expected_pc, return_addr);
    else begin
        $display("JAL instruction FAILED: PC = %0d, $ra = %0d, Expected PC = %0d, Expected $ra = %0d", 
                 DUT.PC_INS.Current_pc, DUT.RegFile_INS.r_mem[31], expected_pc, return_addr);
        $stop;
    end
endtask

endmodule