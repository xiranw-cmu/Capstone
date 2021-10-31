/*
TODO:
1. Generate output file
*/

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef enum opcode {
    MOV  = 0x0,
    ADD  = 0x1,
    SUB  = 0x2,
    AND  = 0x3,
    OR   = 0x4,
    XOR  = 0x5,
    SLL  = 0x6,
    SRL  = 0x7,
    SRA  = 0x8,
    ADDI = 0x9,
    ANDI = 0xa,
    ORI  = 0xb,
    XORI = 0xc,
    SLLI = 0xd,
    SRLI = 0xe,
    SRAI = 0xf
} opcode_t;

void process_instr(char *line, int16_t *reg_file) {
    int16_t instr, opcode, dest_reg, src1_reg, src2_reg, src2_imm;

    instr = strtol(line, NULL, 16); // convert char * to int16_t

    /* Decode instr */
    opcode = (instr >> 12) & 0xF;
    dest_reg = (instr >> 8) & 0xF;
    src1_reg = (instr >> 4) & 0xF;
    src2_reg = instr & 0xF;
    if (src2_reg & 0x8) src2_imm = src2_reg | 0xFFF0; // sign-extend src2_imm
    else src2_imm = src2_reg;
    
    /*printf("instr:%hx, opcode:%hx, dest_reg:%hx, src1_reg:%hx, src2_reg:%hx, src2_imm:%hx\n", 
    instr, opcode, dest_reg, src1_reg, src2_reg, src2_imm);*/

    /* Perform computation */
    switch(opcode) {
        case MOV:  {
            reg_file[dest_reg] = reg_file[src1_reg];
            break;
        }

        case ADD:  {
            reg_file[dest_reg] = reg_file[src1_reg] + reg_file[src2_reg];
            break;
        }

        case SUB:  {
            reg_file[dest_reg] = reg_file[src1_reg] - reg_file[src2_reg];
            break;
        }

        case AND:  {
            reg_file[dest_reg] = reg_file[src1_reg] & reg_file[src2_reg];
            break;
        }

        case OR:   {
            reg_file[dest_reg] = reg_file[src1_reg] | reg_file[src2_reg];
            break;
        }

        case XOR:  {
            reg_file[dest_reg] = reg_file[src1_reg] ^ reg_file[src2_reg];
            break;
        }

        case SLL:  {
            reg_file[dest_reg] = reg_file[src1_reg] << (reg_file[src2_reg] & 0xF); // can only shift by 0 ~ 15
            break;
        }

        case SRL:  {
            // cast to unsigned for logical shift
            reg_file[dest_reg] = (uint16_t)reg_file[src1_reg] >> (reg_file[src2_reg] & 0xF); // can only shift by 0 ~ 15
            break;
        }

        case SRA:  {
            reg_file[dest_reg] = reg_file[src1_reg] >> (reg_file[src2_reg] & 0xF); // can only shift by 0 ~ 15
            break;
        }

        case ADDI: {
            reg_file[dest_reg] = reg_file[src1_reg] + src2_imm;
            break;
        }

        case ANDI: {
            reg_file[dest_reg] = reg_file[src1_reg] & src2_imm;
            break;
        }

        case ORI:  {
            reg_file[dest_reg] = reg_file[src1_reg] | src2_imm;
            break;
        }

        case XORI: {
            reg_file[dest_reg] = reg_file[src1_reg] ^ src2_imm;
            break;
        }

        case SLLI: {
            reg_file[dest_reg] = reg_file[src1_reg] << (src2_imm & 0xF); // can only shift by 0 ~ 15
            break;
        }

        case SRLI: {
            // cast to unsigned for logical shift
            reg_file[dest_reg] = (uint16_t) reg_file[src1_reg] >> (src2_imm & 0xF); // can only shift by 0 ~ 15
            break;
        }

        case SRAI: {
            reg_file[dest_reg] = reg_file[src1_reg] >> (src2_imm & 0xF); // can only shift by 0 ~ 15
            break;
        }

        default:   {
            fprintf(stderr, "Encountered unknown opcode %hx", opcode);
            exit(-1);
        }
    }

    reg_file[0] = 0; // r0 = 0 does not change
}

int main(int argc, char *argv[]) {
    /* Check test case file argument is supplied */
    if (argc < 2) {
        fprintf(stderr, "Usage: ./golden_model <test case file>\n");
        exit(-1);
    }

    struct timespec start_time, end_time;
    clock_gettime(CLOCK_REALTIME, &start_time); // start time for benchmarking

    /* Open test case file */
    FILE *fp = fopen(argv[1], "r");
    if (fp == NULL) {
        fprintf(stderr, "Error: Failed to open file %s\n", argv[1]);
        exit(-1);
    }

    int16_t reg_file[16] = {0}; // init register file

    /* Process test case file line by line */
    ssize_t read;
    char *line = NULL;
    size_t line_size;
    while ((read = getline(&line, &line_size, fp)) != -1) { // stop at end-of-file
        if (read != 5) { // 4 bytes for instr + 1 byte for new line char
            fprintf(stderr, "Error: Encountered %zu-byte line when each line should be 5 bytes\n", read);
            exit(-1);
        }
        process_instr(line, reg_file);
    }

    /*for (int i = 0; i < 16; i++)
        printf("%x: %hx\n", i, reg_file[i]);*/

    free(line);
    fclose(fp);

    clock_gettime(CLOCK_REALTIME, &end_time); // end time for benchmarking
    int runtime = (end_time.tv_sec - start_time.tv_sec) * 1000000000 + (end_time.tv_nsec - start_time.tv_nsec);
    printf("Golden model ran for %d ns\n", runtime);
    
    return 0;
}
