"""
TODO (in order of decreasing priority):
1. Sanitize user input: test case size can only be between 1 to 20,000
2. More questions
3. Would be nice to allow user to specify range to randomize for size
4. Would be nice to have a GUI for this (interface with Google Form?)
"""

import random

# Gather user input
print("\nWelcome to the test case generator!")
print("\nWe will ask 4 questions in order to customize your test case. If you'd like the default option, simply press return.")

print("\n--------------------------------------------------------------------------------------------------------------------")
print("1. Test case file name")
file_name = input("\nEnter the name of the output test case file (default is test_case.txt): ")

if (file_name == ""):
    file_name = "test_case.txt"

print("\n--------------------------------------------------------------------------------------------------------------------")
print("2. Test case size")
num_instrs = input("\nEnter how many instructions to have in your test case (default is random from 1 ~ 20,000): ")

if (num_instrs == ""):
    num_instrs = random.randrange(1, 20001)
else:
    num_instrs = int(num_instrs)

print("\n--------------------------------------------------------------------------------------------------------------------")
print("3. Instructions to test")
print("""\nWe support the following instructions:
0 = MOV, 1 = ADD,  2 = SUB,  3 = AND, 4 = OR,   5 = XOR,  6 = SLL,  7 = SRL,
8 = SRA, 9 = ADDI, a = ANDI, b = ORI, c = XORI, d = SLLI, e = SRLI, f = SRAI
Specify which instructions to test with space-separated numbers (e.g., to test SRL and SRLI, enter 7 e)""")
instr_string = input("\nEnter which instructions to test (default is all): ")

if (instr_string == ""):
    instr_list = [hex(i)[2:] for i in range(16)]
else:
    instr_list = instr_string.split(" ")

print("\n--------------------------------------------------------------------------------------------------------------------")
print("4. Destination registers to test")
print("""\nWe have a total of 16 registers, numbered 0 ~ f.
Specify which registers can be destination registers with space-separated numbers
(e.g., to have 0, 2, and a as destination registers, enter 0 2 a)""")
rd_string = input("\nEnter which registers are destination registers (default is all): ")

if (rd_string == ""):
    rd_list = [hex(i)[2:] for i in range(16)]
else:
    rd_list = rd_string.split(" ")


# Generate test case
with open(file_name, "w") as f:
    for i in range(num_instrs):
        opcode = random.choice(instr_list)
        rd = random.choice(rd_list)
        src1 = random.choice([hex(i)[2:] for i in range(16)])
        src2 = random.choice([hex(i)[2:] for i in range(16)])
        f.write(opcode + rd + src1 + src2 + "\n")

print("\n--------------------------------------------------------------------------------------------------------------------")
print("Test case file %s has been generated!\n" %(file_name))
print("Thank you for using test case generator :)\n")
