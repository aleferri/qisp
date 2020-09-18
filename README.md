# QISP
Queue Instruction Set Processor

Two operand RISC-Like instruction set with implicit destination and addressable register set (using the internal Queue Pointer register)

# Multithreading
Experimental full usage of compute power with auto task switch on branches, as such the pipeline carry the corrisponding thread id (1 bit, since there are two processes) on the next phase.
The architecture has two PC and two register set
