# Helper functions to assist in writing the main game logic
.data
clear_console: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" # Unfortunately spamming newlines is the only way to "clear" our console
.text
ClearConsole:
	la $s0, ($a0) # Take a0 as our saved temp ($s0)
	la $s1, ($a1) # Take a1 as our saved temp ($s1)
	# Just ignore for now.
	la $a0, clear_console
	li $v0, 4 # Syscall code for printf
	syscall

	jr $ra
	
# GenerateSimonList - Allocates and populates a 2D array for the Simon game
# Args:
#   $a0 - dimensions (number of rounds)
#   $a1 - difficulty (number of colors per round)
# Return:
#   $v0 - address of the populated 2D array
GenerateSimonList:
    addi $sp, $sp, -16 # Allocate stack space
    sw $ra, 12($sp) # Save return address
    sw $s0, 8($sp) # Save $s0
    sw $s1, 4($sp) # Save $s1
    sw $s2, 0($sp) # Save $s2

    move $s0, $a0  # $s0 = dimensions
    move $s1, $a1  # $s1 = difficulty

    # Call AllocateArr
    move $a0, $s0 # $a0 = dimensions
    move $a1, $s1 # $a1 = difficulty
    jal AllocateArray # Allocate the 2D array
    move $s2, $v0 # $s2 = address of the allocated array

    # Call PopulateLis
    move $a0, $s0 # $a0 = dimensions
    move $a1, $s1 # $a1 = size (difficulty)
    move $a2, $s2 # $a2 = address of the 2D array
    jal PopulateList # Populate the array with random numbers

    move $v0, $s2 # Return the array address in $v0
	
	# Restore registers
    lw $s2, 0($sp) 
    lw $s1, 4($sp) 
    lw $s0, 8($sp) 
    lw $ra, 12($sp)

	# Deallocate stack space
    addi $sp, $sp, 16
    
	jr $ra 

# AllocateArray - Allocates a 2D integer array
# Args:
#   $a0 - dimensions (number of rows)
#   $a1 - difficulty (number of columns)
# Return:
#   $v0 - address of the allocated 2D array
AllocateArray:
    addi $sp, $sp, -20 # Allocate stack space
    sw $ra, 16($sp) # Save return address
    
	# Backup $s registers
	sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    move $s0, $a0 # $s0 = dimensions
    move $s1, $a1 # $s1 = difficulty

    li $t0, 4 # Size of int pointer
    mul $a0, $s0, $t0 # $a0 = dimensions * 4
    jal malloc # data = malloc(dimensions * sizeof(int*))
    move $s2, $v0 # $s2 = data

    move $s3, $zero # i = 0

AllocateLoop:
    bge $s3, $s0, AllocateEnd # if i >= dimensions, exit loop
    li $t0, 4 # Size of int
    mul $a0, $s1, $t0 # $a0 = difficulty * 4
    jal malloc # data[i] = malloc(difficulty * sizeof(int))
    mul $t1, $s3, 4 # $t1 = i * 4
    add $t2, $s2, $t1 # $t2 = &data[i]
    sw $v0, 0($t2) # Store pointer in data[i]
    addi $s3, $s3, 1 # i++
    j AllocateLoop

AllocateEnd:
    move $v0, $s2 # Return data

	# Restore $s registers
    lw $s3, 0($sp) 
    lw $s2, 4($sp) 
    lw $s1, 8($sp) 
    lw $s0, 12($sp)

	# Restore return address
    lw $ra, 16($sp)

	# Deallocate stack space
    addi $sp, $sp, 20

    jr $ra

# FreeArray - Frees a 2D integer array
# Args:
#   $a0 - address of the 2D array
#   $a1 - dimensions (number of rows)
# Return:
#   None
FreeArray:
	# Allocate stack space
    addi $sp, $sp, -16 
    
	# Backup registers
	sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    move $s0, $a0 # $s0 = data
    move $s1, $a1 # $s1 = dimensions

    move $s2, $zero # i = 0

FreeLoop:
    bge $s2, $s1, FreeEnd # if i >= dimensions, exit loop
    mul $t0, $s2, 4 # $t0 = i * 4
    add $t1, $s0, $t0 # $t1 = &data[i]
    lw $a0, 0($t1) # $a0 = data[i]
    
	jal free # free(data[i])
    
	addi $s2, $s2, 1 # i++
    j FreeLoop

FreeEnd:
    move $a0, $s0 # $a0 = data

    jal free # free(data)

	# Restore registers
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)

	# Deallocate stack space
    addi $sp, $sp, 16
    jr $ra

# PopulateList - Fills a 2D array with random numbers from 0 to 9
# Arguments:
#   $a0 - dimensions (number of rows)
#   $a1 - size (number of columns)
#   $a2 - address of the 2D array (int** list)
# Returns:
#   None
PopulateList:
	# Allocate stack space
    addi $sp, $sp, -20

    # Save registers
	sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp) 
    sw $s2, 4($sp) 
    sw $s3, 0($sp) 

    move $s0, $a0 # $s0 = dimensions
    move $s1, $a1 # $s1 = size
    move $s2, $a2 # $s2 = list

    li $s3, 0 # i = 0

OuterLoop:
    bge $s3, $s0, PopulateEnd # if i >= dimensions, exit loop
    mul $t0, $s3, 4 # $t0 = i * 4
    add $t1, $s2, $t0 # $t1 = &list[i]
    lw $t2, 0($t1) # $t2 = list[i]
    li $t3, 0 # j = 0

InnerLoop:
    bge $t3, $s1, NextRow # if j >= size, go to next row
    mul $t4, $t3, 4 # $t4 = j * 4
    add $t5, $t2, $t4 # $t5 = &list[i][j]
    
	li $v0, 42 # syscall code for rand
    syscall # $v0 = random integer
    
	li $t6, 10 # Modulo 10
    div $v0, $t6 # Divide $v0 by 10
    mfhi $t7 # $t7 = $v0 % 10
    sw $t7, 0($t5) # list[i][j] = $v0 % 10
    addi $t3, $t3, 1 # j++

    j InnerLoop

NextRow:
    addi $s3, $s3, 1            # i++
    j OuterLoop

PopulateEnd:
	# Restore registers
    lw $s3, 0($sp) 
    lw $s2, 4($sp) 
    lw $s1, 8($sp) 
    lw $s0, 12($sp)
    lw $ra, 16($sp)
	
    addi $sp, $sp, 20 # Deallocate stack space
    
	jr $ra