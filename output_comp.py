"""
TODO (in order of decreasing priority):
1. Do error detection for file open errors (jank in Python)
2. Allow user to pass in names of two files to compare
3. Pass in test case too so we can print which instruction went wrong
4. Similar to test_generator.py, would be nice to migrate to GUI
"""

import sys

correct = True

with open('golden_output.txt') as golden_fd, open('sim_output.txt') as sim_fd:
    golden_lines, sim_lines = golden_fd.readlines(), sim_fd.readlines()

    # If number of lines don't match, error in our system
    golden_len, sim_len = len(golden_lines), len(sim_lines)
    if (golden_len != sim_len):
        print("Error: Have %d lines in golden_output.txt but %d lines in sim_output.txt\n" %(golden_len, sim_len))
        sys.exit()
    
    # Compare line by line
    for i in range(golden_len):
        golden_line, sim_line = golden_lines[i], sim_lines[i]

        # If number of chars in lines not 65, error in our system
        golden_line_len, sim_line_len = len(golden_line), len(sim_line)
        if (golden_line_len != 65):
            print("Error: Line %d in golden_output.txt is %d chars, when every line should be 65 chars\n" 
            %(i, golden_line_len))
            sys.exit()
        if (sim_line_len != 65):
            print("Error: Line %d in sim_output.txt is %d chars, when every line should be 65 chars\n"
            %(i, sim_line_len))
            sys.exit()
        
        # If lines don't match, find which register(s) are wrong
        if (golden_line != sim_line):
            for reg in range(16):
                golden_reg, sim_reg = golden_line[4*reg: 4*(reg+1)], sim_line[4*reg: 4*(reg+1)]
                if (golden_reg != sim_reg):
                    print("Error: At instruction %d, register %d should be %s but is %s\n"
                    %(i, reg, golden_reg, sim_reg))
            correct = False
            break # No need to compare further, rest will be wrong too

    if (correct):
        print("No errors spotted!")
    
    print("Output comparison complete.")
