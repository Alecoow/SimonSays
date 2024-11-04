# Helper functions to assist in writing the main game logic

.data
clear_console: .asciiz "\n\n\n\n\n" # Unfortunately spamming newlines is the only way to "clear" our console

.text
ClearConsole:
	la $s0, ($a0) # Take a0 as our saved temp ($s0)
	la $s1, ($a1) # Take a1 as our saved temp ($s1)
    # Just ignore for now.
	la $a0, clear_console
	li $v0, 4 # Syscall code for printf
	syscall

    jr $ra

GenerateSimonList: # This function doesn't really need to exist, but is a PoC of nested function calls
addi $sp, -4 # push caller return address to stack
sw $ra, 0($sp)

jal AllocateArray # jal to Allocate enough memory to store our 2D array

jal PopulateList # jal to Populate that new array with random numbers

lw $ra, 0($ra) # restore return address
jr $ra 

AllocateArray: # TODO: finish
	lw $t0, 0(dimensions) # rows
	lw $t1, 0(difficulty) # columns
	mul $t0, $t0, $t1
	li $a0, $t0
	
	addi $sp, -4 # store caller return address to stack
	sw $ra, 0($sp)
	

	jal malloc # jump to memory allocator

	jr $ra