# Various functions to help with transitioning from C to Assembly
.data
time_struct_low: 		.word	0
time_struct_high: 		.word	0
rand_seed:				.word	0
.text

# print_message - Prints a null-terminated string to the console
# Arguments:
#   $a0 - address of the string to print
# Returns:
#   None
print_message:
	li $v0, 4 # Syscall code for printf
	syscall
	jr $ra

# print_int - Prints an integer to the console
# Arguments:
#   $a0 - integer value to print
# Returns:
#   None
print_int:
	li $v0, 1 # Syscall code for print int
	syscall
	jr $ra

# malloc - Allocates memory on the heap
# Arguments:
#   $a0 - size in bytes to allocate
# Returns:
#   $v0 - address of allocated memory
malloc: # void* malloc(size_t size) takes $a0 as argument, return val goes into $v0
	li $v0, 9 # Syscall code for sbrk (heap allocate)
	syscall
	jr $ra

# free - Frees allocated memory
# Arguments:
#   $a0 - pointer to memory to free
#   $a1 - size in bytes of the memory block
# Returns:
#   None
free: # void free(void* ptr, size_t size)
	# Check if size is zero or negative
	blez $a1, free_exit # if size <= 0 goto free_exit
	and $t0, $a0, $a0
free_loop:
	sb $zero, 0($t0) # a0[i] = NULL
	addi $t0, $t0, 1  # i++
	addi $a1, $a1, -1 # size--
	bgtz $a1, free_loop # while (size)
free_exit:
    jr $ra

# sleep - Pauses execution for a specified time
# Arguments:
#   $a0 - number of milliseconds to sleep
# Returns:
#   None
sleep: # sleep(ms)
	li $v0, 32 # Syscall code for sleep (ms)
	syscall
	jr $ra

# getc - Reads a character from input
# Arguments:
#   None
# Returns:
#   $v0 - character read from input
getc: # char getc() ($v0 is our character)
	li $v0, 12 # Syscall code for read character
	syscall
	jr $ra

# time - Retrieves the current system time as 2 seperate low and high values
# Arguments:
#   None
# Returns:
#   $v0 - low dword of time since epoch
#	$v1 - high dword of time since epoch
time: # time_struct time()
	# For some reason, the return is on a0 and a1 instead of v0 and v1 like every other syscall
	li $v0, 30 # Syscall code for get time
	syscall
	# Store a0 and a1 into return values
	move $v0, $a0
	move $v1, $a1
	# Return to caller
	jr $ra

play_sound_correct:
	li $a0, 119 # pitch
	li $a1, 100 # duration
	li $a2, 9 # instrument
	li $a3, 100 # volume
	li $v0, 33 # Syscall code for play sound
	syscall
	jr $ra

play_sound_incorrect:
	li $a0, 30 # pitch
	li $a1, 100 # duration
	li $a2, 25 # instrument
	li $a3, 100 # volume
	li $v0, 33 # Syscall code for play sound
	syscall
	jr $ra

# rand - Generates a pseudo-random number using an LFSR algorithm
# Arguments:
#   None
# Returns:
#   $v0 - pseudo-random number
rand:
    # Reserve stack space
    addi $sp, $sp, -4
    # Save the return address
    sw $ra, 0($sp)

    # Load the current seed
    lw $t0, rand_seed

    # If seed is zero, initialize it using time
    bnez $t0, shift

    # Seed is zero, initialize it
    jal time
	move $t0, $a0	

shift:
    # Get bit 0 (LSB) and bit 21
    andi $t1, $t0, 1 # t1 = bit 0
    srl $t2, $t0, 21
    andi $t2, $t2, 1 # t2 = bit 21
    xor $t1, $t1, $t2 # t1 = bit 0 XOR bit 21

    # Shift seed right by 1
    srl $t0, $t0, 1

    # Place the new bit in the seed
    sll $t1, $t1, 30
    or $t0, $t0, $t1 # Insert new bit

    # Store the new seed
    sw $t0, rand_seed

    # Move the generated random number to $v0
	andi $v0, $t0, 0x7F # Mask off the sign bit

    # Restore stack space
    lw $ra, 0($sp) # Restore return address
    addi $sp, $sp, 4

    # Return to caller
    jr $ra

# exit - Exits the program
# Arguments:
#   None
# Returns:
#   None
exit:
	li $v0, 10 # Exit
	syscall
	jr $ra