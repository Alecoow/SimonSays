# Helper functions to assist in writing the main game logic
.data
clear_console: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" # Unfortunately spamming newlines is the only way to "clear" our console

.text
# ClearConsole - Sends a bunch of newlines to clear our console
# Args:
#	None
# Returns:
#	None
ClearConsole:	
	# Reserve some stack space for our return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, clear_console
	jal print_message
	lw $ra, 0($sp)
	# Restore stack space
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

	# Call AllocateArray
	move $a0, $s0 # $a0 = dimensions
	move $a1, $s1 # $a1 = difficulty
	jal AllocateArray # Allocate the 2D array
	move $s2, $v0 # $s2 = address of the allocated array

	# Call PopulateList
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
	
	# Save $t registers
	addi $sp, $sp, -16 # Allocate stack space
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)

	jal rand # $v0 = rand()

	# Restore $t registers
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	addi $sp, $sp, 16 # Deallocate stack space
	
	li $t6, 10 # Modulo 10
	div $v0, $t6 # Divide $v0 by 10
	mfhi $t7 # $t7 = $v0 % 10
	sw $t7, 0($t5) # list[i][j] = $v0 % 10
	addi $t3, $t3, 1 # j++

	j InnerLoop

NextRow:
	addi $s3, $s3, 1 # i++
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

# FlattenArray - Flattens a 2D array into a 1D array
# Args:
#   $a0 - address of the 2D array (simon_numbers)
#   $a1 - dimensions (number of rows)
#   $a2 - difficulty (number of columns)
#   $a3 - address of the flattened array
# Returns:
#   None
FlattenArray:
	# Save registers
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, 0($sp)

	move $s0, $a0 # $s0 = simon_numbers
	move $s1, $a1 # $s1 = dimensions
	move $s2, $a2 # $s2 = difficulty
	move $t0, $a3 # $t0 = flattened_array pointer

    li $t1, 0 # i = 0

flatten_outer_loop:
	bge $t1, $s1, flatten_end
	mul $t2, $t1, 4 # t2 = i * 4
	add $t3, $s0, $t2 # t3 = &simon_numbers[i]
	lw $t4, 0($t3) # t4 = simon_numbers[i]
	li $t5, 0 # j = 0

flatten_inner_loop:
	bge $t5, $s2, flatten_inner_end
	mul $t6, $t5, 4 # t6 = j * 4
	add $t7, $t4, $t6 # t7 = &simon_numbers[i][j]
	lw $t8, 0($t7) # t8 = simon_numbers[i][j]

	# Store into flattened_array
	sw $t8, 0($t0)
	addi $t0, $t0, 4 # Move to next position

	addi $t5, $t5, 1 # j++
	j flatten_inner_loop

flatten_inner_end:
	addi $t1, $t1, 1 # i++
	j flatten_outer_loop

flatten_end:
	# Restore registers
	lw $s2, 0($sp)
	lw $s1, 4($sp)
	lw $s0, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra

# CompareAnswer - Compares user input against the expected sequence
# Args:
#   $a0 - address of the user input buffer
#   $a1 - address of the flattened array
#   $a2 - length of the flattened array (dimensions * difficulty)
# Returns:
#   $v0 - 1 if the input matches the expected sequence, 0 if it doesn't, -1 if the input is invalid
CompareAnswer:
	# Save registers
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)

	move $s0, $a2 # length
	li $t0, 0 # index = 0
	li $t1, 0 # input index = 0

compare_loop:
	bge $t0, $s0, compare_success # If all elements matched, success

	lb $t2, 0($a0) # Load next character
	beq $t2, $zero, compare_failure # End of string before expected

	# Skip commas and whitespace
	beq $t2, ',', skip_char
	beq $t2, ' ', skip_char
	beq $t2, '\n', skip_char

	# Convert char to int
	subi $t2, $t2, 48
	blt $t2, 0, compare_invalid # Not a digit
	bgt $t2, 9, compare_invalid # Not a digit

	# Load expected number
	lw $t3, 0($a1) # bug here
	beq $t2, $t3, match_number
	j compare_failure

match_number:
	addi $a1, $a1, 4 # Move to next expected number
	addi $t0, $t0, 1 # index++
	j skip_char

skip_char:
	addi $a0, $a0, 1 # input index++
	j compare_loop

compare_success:
	jal play_sound_correct
	li $v0, 1 # Return 1 for correct
	j compare_exit

compare_failure:
	jal play_sound_incorrect
	jal play_sound_incorrect
	li $v0, 0 # Return 0 for incorrect
	j compare_exit

compare_invalid:
	li $v0, -1 # Return -1 for invalid input

compare_exit:
	# Restore registers
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

# Start_Random_Event:
#	addi $sp, $sp, -4
#	sw $ra, 0($sp)
#
#	jal rand
#
#	lw $ra, 0($sp)
#	addi $sp, $sp, 4
#
#	jle $v0, 5, Random_Event_Start # If the random number is less than or equal to 5, start the random event
#	jr $ra
#
#Random_Event_Start:
#	jle $v0, 1, Random_Event_1 # If the random number is less than or equal to 1, start random event 1
#	jle $v0, 3, Random_Event_2 # If the random number is less than or equal to 3, start random event 2
#	j Random_Event_3 # Otherwise, start random event 3
#Random_Event_1:
#	# random score_multiplier
#Random_Event_2:
#	# random time_multiplier
#Random_Event_3:
#	# double_or_nothing
