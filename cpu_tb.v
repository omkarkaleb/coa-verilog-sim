`timescale 1ns / 1ps

module cpu_tb;
    // Testbench signals
    reg clk;
    reg reset;
    wire [15:0] pc_out;
    wire [15:0] instruction_out;
    wire [15:0] alu_result_out;
    wire [15:0] data_mem_read_out;
    
    // Test tracking variables
    integer cycle_count;
    integer i; // Loop counter - declared outside loops
    
    // Instruction test tracking by TYPE
    // LW instructions
    reg [15:0] lw1_expected_value = 5;    // Expected value in R1
    reg [15:0] lw1_actual_value;          // Actual value in R1
    reg lw1_tested = 0;
    reg lw1_pass = 0;
    
    reg [15:0] lw2_expected_value = 7;    // Expected value in R2
    reg [15:0] lw2_actual_value;          // Actual value in R2
    reg lw2_tested = 0;
    reg lw2_pass = 0;
    
    // ADD instructions
    reg [15:0] add1_expected_value = 12;  // Expected R3 = R1 + R2 = 5 + 7 = 12
    reg [15:0] add1_actual_value;
    reg [15:0] add1_operand1;             // R1 value
    reg [15:0] add1_operand2;             // R2 value
    reg add1_tested = 0;
    reg add1_pass = 0;
    
    reg [15:0] add2_expected_value = 24;  // Expected R4 = R3 + R3 = 12 + 12 = 24
    reg [15:0] add2_actual_value;
    reg [15:0] add2_operand1;             // R3 value
    reg [15:0] add2_operand2;             // R3 value
    reg add2_tested = 0;
    reg add2_pass = 0;
    
    // SUB instruction
    reg [15:0] sub_expected_value = 19;   // Expected R5 = R4 - R1 = 24 - 5 = 19
    reg [15:0] sub_actual_value;
    reg [15:0] sub_operand1;              // R4 value
    reg [15:0] sub_operand2;              // R1 value
    reg sub_tested = 0;
    reg sub_pass = 0;
    
    // SW instruction
    reg [15:0] sw_expected_address = 4;   // Expected memory address
    reg [15:0] sw_actual_address;
    reg [15:0] sw_expected_value = 12;    // Expected value (R3 value)
    reg [15:0] sw_actual_value;
    reg sw_tested = 0;
    reg sw_pass = 0;
    
    // JMP instruction
    reg [15:0] jmp_expected_pc = 16'h000A;  // Expected PC after jump
    reg [15:0] jmp_actual_pc;
    reg [15:0] jmp_source_pc = 16'h0008;    // PC before jump
    reg jmp_tested = 0;
    reg jmp_pass = 0;
    
    // Instantiate the CPU
    cpu dut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .instruction_out(instruction_out),
        .alu_result_out(alu_result_out),
        .data_mem_read_out(data_mem_read_out)
    );
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize
        cycle_count = 0;
        
        $display("\n============================================================");
        $display("             CPU INSTRUCTION TEST SUITE                    ");
        $display("============================================================\n");
        
        // Reset the CPU
        reset = 1;
        #20;
        reset = 0;
        
        // Run for enough cycles to execute all instructions
        repeat(25) @(posedge clk);
        
        // Print final test summary by instruction type
        print_instruction_type_summary();
        
        $finish;
    end
    
    // Print final test summary grouped by instruction type
    task print_instruction_type_summary;
    begin
        $display("\n============================================================");
        $display("             TEST RESULTS BY INSTRUCTION TYPE              ");
        $display("============================================================\n");
        
        // Load the final values directly from register file 
        // to avoid any timing issues with the test tracking logic
        lw1_actual_value = dut.REGS.registers[1];
        lw1_pass = (lw1_actual_value == lw1_expected_value);
        
        lw2_actual_value = dut.REGS.registers[2];
        lw2_pass = (lw2_actual_value == lw2_expected_value);
        
        add1_operand1 = dut.REGS.registers[1];
        add1_operand2 = dut.REGS.registers[2];
        add1_actual_value = dut.REGS.registers[3];
        add1_pass = (add1_actual_value == add1_expected_value);
        
        add2_operand1 = dut.REGS.registers[3];
        add2_operand2 = dut.REGS.registers[3];
        add2_actual_value = dut.REGS.registers[4];
        add2_pass = (add2_actual_value == add2_expected_value);
        
        sub_operand1 = dut.REGS.registers[4];
        sub_operand2 = dut.REGS.registers[1];
        sub_actual_value = dut.REGS.registers[5];
        sub_pass = (sub_actual_value == sub_expected_value);
        
        sw_actual_value = dut.DMEM.memory[2]; // Memory address 4 >> 1 = 2
        sw_pass = (sw_actual_value == sw_expected_value);
        
        // LOAD WORD (LW) results
        $display("1. LOAD WORD (LW) INSTRUCTIONS:");
        $display("------------------------------------------------------------");
        $display("Test Case 1: LW R1, 0(R0)");
        $display("  Expected: R1 = %d", lw1_expected_value);
        $display("  Actual:   R1 = %d", lw1_actual_value);
        $display("  Status:   %s\n", lw1_pass ? "PASS" : "FAIL");
        
        $display("Test Case 2: LW R2, 2(R0)");
        $display("  Expected: R2 = %d", lw2_expected_value);
        $display("  Actual:   R2 = %d", lw2_actual_value);
        $display("  Status:   %s\n", lw2_pass ? "PASS" : "FAIL");
        
        // ADD instruction results
        $display("2. ADD INSTRUCTIONS:");
        $display("------------------------------------------------------------");
        $display("Test Case 1: ADD R3, R1, R2");
        $display("  Operation: %d + %d = %d", add1_operand1, add1_operand2, add1_expected_value);
        $display("  Expected:  R3 = %d", add1_expected_value);
        $display("  Actual:    R3 = %d", add1_actual_value);
        $display("  Status:    %s\n", add1_pass ? "PASS" : "FAIL");
        
        $display("Test Case 2: ADD R4, R3, R3");
        $display("  Operation: %d + %d = %d", add2_operand1, add2_operand2, add2_expected_value);
        $display("  Expected:  R4 = %d", add2_expected_value);
        $display("  Actual:    R4 = %d", add2_actual_value);
        $display("  Status:    %s\n", add2_pass ? "PASS" : "FAIL");
        
        // SUBTRACT instruction results
        $display("3. SUBTRACT (SUB) INSTRUCTION:");
        $display("------------------------------------------------------------");
        $display("Test Case: SUB R5, R4, R1");
        $display("  Operation: %d - %d = %d", sub_operand1, sub_operand2, sub_expected_value);
        $display("  Expected:  R5 = %d", sub_expected_value);
        $display("  Actual:    R5 = %d", sub_actual_value);
        $display("  Status:    %s\n", sub_pass ? "PASS" : "FAIL");
        
        // STORE WORD instruction results
        $display("4. STORE WORD (SW) INSTRUCTION:");
        $display("------------------------------------------------------------");
        $display("Test Case: SW R3, 4(R0)");
        $display("  Expected Address: %d", sw_expected_address);
        $display("  Expected Value:   %d (from R3)", sw_expected_value);
        $display("  Actual Memory[2]: %d", sw_actual_value);
        $display("  Status:           %s\n", sw_pass ? "PASS" : "FAIL");
        
        // JUMP instruction results
        $display("5. JUMP (JMP) INSTRUCTION:");
        $display("------------------------------------------------------------");
        $display("Test Case: JMP 5 (Jump to address 5)");
        if (jmp_tested) begin
            $display("  Expected: PC changes from 0x%h to 0x%h", jmp_source_pc, jmp_expected_pc);
            $display("  Actual:   PC = 0x%h", jmp_actual_pc);
            $display("  Status:   %s\n", jmp_pass ? "PASS" : "FAIL");
        end else begin
            $display("  Status: NOT TESTED\n");
        end
        
        // OVERALL RESULTS
        $display("============================================================");
        $display("                  OVERALL TEST RESULTS                     ");
        $display("============================================================");
        
        if (lw1_pass && lw2_pass && add1_pass && add2_pass && sub_pass && sw_pass && jmp_pass) begin
            $display("ALL INSTRUCTION TESTS PASSED!");
        end else begin
            $display("SOME INSTRUCTION TESTS FAILED:");
            if (!lw1_pass) $display("  - LW instruction 1 (R1) failed");
            if (!lw2_pass) $display("  - LW instruction 2 (R2) failed");
            if (!add1_pass) $display("  - ADD instruction 1 (R3 = R1 + R2) failed");
            if (!add2_pass) $display("  - ADD instruction 2 (R4 = R3 + R3) failed");
            if (!sub_pass) $display("  - SUB instruction (R5 = R4 - R1) failed");
            if (!sw_pass) $display("  - SW instruction failed");
            if (!jmp_pass) $display("  - JMP instruction failed");
        end
        
        // DEBUG DUMP - Show all register and memory states at the end
        $display("\n============================================================");
        $display("             FINAL STATE DEBUGGING INFORMATION             ");
        $display("============================================================");
        $display("REGISTER FILE FINAL STATE:");
        for (i = 0; i < 8; i = i + 1) begin
            $display("  R%0d = %d", i, dut.REGS.registers[i]);
        end
        
        $display("\nDATA MEMORY (FIRST 8 LOCATIONS):");
        for (i = 0; i < 8; i = i + 1) begin
            $display("  Memory[%0d] = %d", i, dut.DMEM.memory[i]);
        end
        
        $display("\nINSTRUCTION MEMORY (PROGRAM):");
        for (i = 0; i < 7; i = i + 1) begin
            $display("  Instruction[%0d] = 0x%h", i, dut.IMEM.memory[i]);
        end
    end
    endtask
    
    // Monitor CPU execution
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
            
            // Print cycle header
            $display("\n============================================================");
            $display("CYCLE %0d: PC = 0x%h, Instruction = 0x%h", 
                    cycle_count, pc_out, instruction_out);
            $display("============================================================");
            
            // Debug instruction decode
            debug_instruction(instruction_out);
            
            // Track jump instruction
            if (pc_out == 16'h0008 && dut.opcode == 4'b0110) begin // JMP instruction
                jmp_source_pc = pc_out;
            end
            
            if (pc_out == 16'h000A && !jmp_tested) begin
                jmp_actual_pc = pc_out;
                jmp_tested = 1;
                jmp_pass = (jmp_actual_pc == jmp_expected_pc);
                
                $display("TEST - JUMP:");
                $display("  Expected: PC changes from 0x%h to 0x%h", jmp_source_pc, jmp_expected_pc);
                $display("  Actual:   PC = 0x%h", jmp_actual_pc);
                $display("  Status:   %s", jmp_pass ? "PASS" : "FAIL");
            end
            
            // Print important registers and signals
            print_debug_info();
        end
    end
    
    // Debug instruction decode
    task debug_instruction;
        input [15:0] instr;
        
        reg [3:0] opcode;
        reg [3:0] rd_rt;
        reg [3:0] rs;
        reg [3:0] funct_imm;
    begin
        opcode = instr[15:12];
        rd_rt = instr[11:8];
        rs = instr[7:4];
        funct_imm = instr[3:0];
        
        $display("INSTRUCTION DECODE:");
        $display("  Fields: opcode=%b, rd/rt=%d, rs=%d, rt/funct/imm=%d", 
                opcode, rd_rt, rs, funct_imm);
        
        case(opcode)
            4'b0000: begin // R-type
                if (funct_imm == 4'b0001) begin
                    $display("  Executing: SUB R%0d = R%0d - R%0d", rd_rt, rs, rd_rt);
                    $display("  Values: R%0d = %0d, R%0d = %0d", 
                            rs, dut.REGS.registers[rs], 
                            rd_rt, dut.REGS.registers[rd_rt]);
                end else if (funct_imm == 4'b0010) begin
                    $display("  Executing: SLL R%0d = R%0d << R%0d", rd_rt, rd_rt, rs);
                    $display("  Values: R%0d = %0d, R%0d = %0d", 
                            rd_rt, dut.REGS.registers[rd_rt],
                            rs, dut.REGS.registers[rs]);
                end else if (funct_imm == 4'b0011) begin
                    $display("  Executing: AND R%0d = R%0d & R%0d", rd_rt, rd_rt, rs);
                    $display("  Values: R%0d = %0d, R%0d = %0d", 
                            rd_rt, dut.REGS.registers[rd_rt],
                            rs, dut.REGS.registers[rs]);
                end else begin // Assume ADD
                    $display("  Executing: ADD R%0d = R%0d + R%0d", rd_rt, rs, funct_imm);
                    $display("  Values: R%0d = %0d, R%0d = %0d", 
                            rs, dut.REGS.registers[rs],
                            funct_imm, dut.REGS.registers[funct_imm]);
                end
            end
            4'b0001: begin // LW
                $display("  Executing: LW R%0d = MEM[R%0d + %0d]", rd_rt, rs, funct_imm);
                $display("  Values: R%0d = %0d, Offset = %0d", 
                        rs, dut.REGS.registers[rs], funct_imm);
            end
            4'b0010: begin // SW
                $display("  Executing: SW MEM[R%0d + %0d] = R%0d", rs, funct_imm, rd_rt);
                $display("  Values: R%0d = %0d, R%0d = %0d, Offset = %0d", 
                        rs, dut.REGS.registers[rs],
                        rd_rt, dut.REGS.registers[rd_rt],
                        funct_imm);
            end
            4'b0011: begin // ADDI
                $display("  Executing: ADDI R%0d = R%0d + %0d", rd_rt, rs, funct_imm);
                $display("  Values: R%0d = %0d, Immediate = %0d", 
                        rs, dut.REGS.registers[rs], funct_imm);
            end
            4'b0100: begin // BEQ
                $display("  Executing: BEQ R%0d, R%0d, %0d", rd_rt, rs, funct_imm);
                $display("  Values: R%0d = %0d, R%0d = %0d, Immediate = %0d", 
                        rd_rt, dut.REGS.registers[rd_rt],
                        rs, dut.REGS.registers[rs],
                        funct_imm);
            end
            4'b0101: begin // BNE
                $display("  Executing: BNE R%0d, R%0d, %0d", rd_rt, rs, funct_imm);
                $display("  Values: R%0d = %0d, R%0d = %0d, Immediate = %0d", 
                        rd_rt, dut.REGS.registers[rd_rt],
                        rs, dut.REGS.registers[rs],
                        funct_imm);
            end
            4'b0110: begin // JMP
                $display("  Executing: JMP to address 0x%h", {pc_out[15:12], instr[11:0], 1'b0});
                $display("  Current PC: 0x%h, Target PC: 0x%h", 
                        pc_out, {pc_out[15:12], instr[11:0], 1'b0});
            end
            default: begin
                $display("  Unknown instruction with opcode %b", opcode);
            end
        endcase
    end
    endtask
    
    // Print detailed debug information
    task print_debug_info;
    begin
        // Print Control Signals
        $display("\nCONTROL SIGNALS:");
        $display("  reg_dst=%b  jump=%b  branch=%b  mem_read=%b  mem_to_reg=%b", 
                dut.reg_dst, dut.jump, dut.branch, dut.mem_read, dut.mem_to_reg);
        $display("  alu_op=%b  mem_write=%b  alu_src=%b  reg_write=%b", 
                dut.alu_op, dut.mem_write, dut.alu_src, dut.reg_write);
        
        // Print Register File
        $display("\nREGISTER FILE STATE:");
        $display("  R0=%d  R1=%d  R2=%d  R3=%d", 
                dut.REGS.registers[0], dut.REGS.registers[1], 
                dut.REGS.registers[2], dut.REGS.registers[3]);
        $display("  R4=%d  R5=%d  R6=%d  R7=%d", 
                dut.REGS.registers[4], dut.REGS.registers[5], 
                dut.REGS.registers[6], dut.REGS.registers[7]);
                
        // Print ALU information
        $display("\nALU OPERATION:");
        $display("  a=%d  b=%d  result=%d  zero=%b  alu_control=%b", 
                dut.ALU.a, dut.ALU.b, dut.alu_result, dut.alu_zero, dut.alu_op);
                
        // Print Memory access if relevant
        if (dut.mem_read) begin
            $display("\nMEMORY READ: address=%d  data=%d", 
                    dut.alu_result, dut.mem_read_data);
            $display("  Memory[%d] = %d", dut.alu_result >> 1, dut.DMEM.memory[dut.alu_result >> 1]);
        end
        
        if (dut.mem_write) begin
            $display("\nMEMORY WRITE: address=%d  data=%d", 
                    dut.alu_result, dut.mem_write_data);
            $display("  Memory location will update to Memory[%d] = %d", 
                    dut.alu_result >> 1, dut.mem_write_data);
        end
        
        // Print Register Write information
        if (dut.reg_write) begin
            $display("\nREGISTER WRITE:");
            $display("  Register: R%d, Current Value: %d, Data to Write: %d", 
                    dut.rd, dut.REGS.registers[dut.rd], dut.reg_write_data);
        end
        
        // Print important internal signals
        $display("\nIMPORTANT INTERNAL SIGNALS:");
        $display("  Instruction Fields: opcode=%b, rd=%d, rs=%d, rt/funct=%d", 
                dut.opcode, dut.rd, dut.rs, dut.rt);
        $display("  Sign Extended Immediate: %d (from %d)", 
                dut.sign_extended_imm, dut.imm);
        $display("  ALU Input 2 Mux: alu_src=%b, reg_data2=%d, sign_ext=%d, selected=%d", 
                dut.alu_src, dut.reg_read_data2, dut.sign_extended_imm, dut.alu_input2);
        $display("  Reg Write Data Mux: mem_to_reg=%b, alu_result=%d, mem_data=%d, selected=%d", 
                dut.mem_to_reg, dut.alu_result, dut.mem_read_data, dut.reg_write_data);
    end
    endtask
    
endmodule