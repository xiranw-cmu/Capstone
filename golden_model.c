#include <stdio.h>
#include <stdlib.h>

void process_instr(char *line, int16_t *reg_file) {
    int16_t instr = strtol(line, NULL, 16); // convert char * to int16_t
    printf("%x\n", instr);
}

int main(int argc, char *argv[]) {
    /* Check test case file argument is supplied */
    if (argc < 2) {
        fprintf(stderr, "Usage: ./golden_model <test case file>\n");
        exit(-1);
    }

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
        if (read != 3) { // 2 bytes for instr + 1 byte for new line char
            fprintf(stderr, "Error: Encountered %zu-byte line when each line should be 3 bytes\n", read);
            exit(-1);
        }
        process_instr(line, reg_file);
    }

    free(line);
    fclose(fp);
    return 0;
}
