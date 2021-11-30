`default_nettype none

typedef enum logic [3:0] {
    MOV  = 4'h0,
    ADD  = 4'h1,
    SUB  = 4'h2,
    AND  = 4'h3,
    OR   = 4'h4,
    XOR  = 4'h5,
    SLL  = 4'h6,
    SRL  = 4'h7,
    SRA  = 4'h8,
    ADDI = 4'h9,
    ANDI = 4'ha,
    ORI  = 4'hb,
    XORI = 4'hc,
    SLLI = 4'hd,
    SRLI = 4'he,
    SRAI = 4'hf
} opcode_t;


module Decoder
    (input  logic 		 instr_valid,
     input  logic [15:0] instr,
     output logic 		 is_src2_imm, rd_we,
     output logic [3:0]  opcode, rd, rs1, src2);

    assign opcode = instr[15:12];
    assign rd     = instr[11:8];
    assign rs1    = instr[7:4];
    assign src2   = instr[3:0];

    assign is_src2_imm = (opcode == ADDI) ||
                         (opcode == ANDI) ||
                         (opcode == ORI)  ||
                         (opcode == XORI) ||
                         (opcode == SLLI) ||
                         (opcode == SRLI) ||
                         (opcode == SRAI);

    // Every valid instr writes to RF, except r0 is never written to
    assign rd_we = instr_valid && (rd != 4'd0);

endmodule: Decoder


module Register_file
    (input  logic 		 clock, reset_n, 
     input  logic		 rd_we,
     input  logic [3:0]  rd, rs1, rs2, ro, // ro stands for read only
     input  logic [15:0] rd_data,
     output logic [15:0] rs1_data, rs2_data, ro_data);

    logic [15:0][15:0] registers;

    // Async read
    assign rs1_data = registers[rs1];
    assign rs2_data = registers[rs2];
    assign ro_data = registers[ro];

    // Sync write
    always_ff @(posedge clock, negedge reset_n) begin
        if (~reset_n)
            registers <= 'b0;
        else if (rd_we)
            registers[rd] <= rd_data;
    end

endmodule: Register_file


module ALU
    (input  logic  [3:0] opcode,
     input  logic [15:0] alu_src1, alu_src2,
     output logic [15:0] alu_out);
    
    always_comb begin
        casez (opcode)
            MOV:  		alu_out = alu_src1;
            ADD, ADDI:  alu_out = alu_src1 + alu_src2;
            SUB:  		alu_out = alu_src1 - alu_src2;
            AND, ANDI:  alu_out = alu_src1 & alu_src2;
            OR,  ORI:   alu_out = alu_src1 | alu_src2;
            XOR, XORI:  alu_out = alu_src1 ^ alu_src2;
            // For shifts, can only shift by 0~15
            SLL, SLLI:  alu_out = alu_src1 << (alu_src2[3:0]);
            SRL, SRLI:  alu_out = alu_src1 >> (alu_src2[3:0]);
            SRA, SRAI:  alu_out = signed'(alu_src1) >>> (alu_src2[3:0]); // cast to signed and use >>> for sign extension
        endcase
    end

endmodule: ALU


module Core
    (input  logic 		clock, reset_n,
     input  logic 	    instr_valid,
     input  logic [15:0] instr,
     output logic [19:0] reg_dump);

    logic is_src2_imm, rd_we;
    logic [3:0] opcode, rd, rs1, src2, ro;
    logic [15:0] rd_data, rs1_data, rs2_data, ro_data;
    logic [15:0] se_immediate, alu_src2;

    // saves data to be sent for next cycle
    assign reg_dump = {ro_data, ro};
    always_ff @(posedge clock)
        ro <= rd;
    
    // Sign extend src2
    assign se_immediate = {{12{src2[3]}}, src2};
    
    // Choose alu_src2 (either rs2_data or se_immediate)
    assign alu_src2 = (is_src2_imm) ? se_immediate : rs2_data;

    Decoder decoder (.instr_valid(instr_valid), 
                     .instr(instr),
                     .is_src2_imm(is_src2_imm), .rd_we(rd_we),
                     .opcode(opcode), .rd(rd), .rs1(rs1), .src2(src2));
    
    Register_file rf (.clock(clock), .reset_n(reset_n),
                      .rd_we(rd_we), 
                      .rd(rd), .rs1(rs1), .rs2(src2), .ro(ro),
                      .rd_data(rd_data), 
                      .rs1_data(rs1_data), .rs2_data(rs2_data), .ro_data(ro_data));
    
    ALU alu (.opcode(opcode),
             .alu_src1(rs1_data), .alu_src2(alu_src2),
             .alu_out(rd_data));

endmodule: Core


module TB();
    // For DUT
    logic clock, reset_n;
    logic instr_valid;
    logic [15:0] instr;
    logic [19:0] reg_dump;

    // For file reading and writing
    string test_case_file;
    int test_fd, output_fd;
    int line = 0;
    logic [15:0] file_instr;

    Core DUT (.*);

    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        /* Check test case file argument is supplied */
        if (!$value$plusargs("TEST=%s", test_case_file)) 
            $display("Usage: ./simv +TEST=<test case file>");

        /* Open test case file and output file */
        test_fd = $fopen(test_case_file, "r");
        if (!test_fd)
            $fatal("Error: Failed to open file %s\n", test_case_file);
        output_fd = $fopen("sim_output.txt", "w");
        if (!output_fd)
            $fatal("Error: Failed to open file sim_output.txt\n");
        
        /* Process test case file line by line */
        while (!$feof(test_fd)) begin
            $fscanf(test_fd, "%h\n", file_instr);

            // First instruction, need to reset
            if (line == 0) begin
                reset_n <= 1'b0;
                @(posedge clock);
        
                reset_n <= 1'b1;  instr_valid <= 1'b1; instr <= file_instr;
                @(posedge clock);
            end
            
            else begin
                instr <= file_instr;
                @(posedge clock);

                // Write register dump to output file
                for (int i = 0; i < 16; i++)
                    $fwrite(output_fd, "%h", DUT.rf.registers[i]);
                $fwrite(output_fd, "\n");
            end
            
            line++;
        end
        
        instr_valid <= 1'b0;
        @(posedge clock); // Need extra clock for last instruction to propagate
        // Write register dump to output file
        for (int i = 0; i < 16; i++)
            $fwrite(output_fd, "%h", DUT.rf.registers[i]);
        $fwrite(output_fd, "\n");

        $display("DUT simulation finished. Output in sim_output.txt");
        
        /* Clean up */
        $fclose(test_fd);
        $fclose(output_fd);
        $finish;
    end

endmodule
