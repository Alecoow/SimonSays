# Various functions to help with transitioning from C to Assembly
.data
time_struct_low: 		.word	0
time_struct_high: 		.word	0
rand_seed:				.word 	0
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
	# It does not like using v0 directly, so use these temp values to store them.
	la $t0, time_struct_low
	la $t1, time_struct_high
	li $v0, 30 # Syscall code for get time
	syscall
	# Store a0 and a1 into temp values
	sw $a0, ($t0)
	sw $a1, ($t1)
	# Set v0 and v1
	la $v0, time_struct_low
	la $v1, time_struct_high
	# Return to caller
	jr $ra

# rand - Generates a pseudo-random number using a LFSR algorithm
# Arguments:
#   None
# Returns:
#   $v0 - pseudo-random number
rand:
	# Clear temp register
	la $t0, ($zero)
	# Save the return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal time
	lw $ra, 0($sp)
	lw $t0, ($v0) # Seed with the first four bytes of time_struct
	
	andi $t1, $t0, 1 # Get the least significant bit
	srl $t0, $t0, 1 # Shift right by 1
	beqz $t1, after # If LSB is 0, skip XOR
	li $t2, 0xB400 # Load initial value (Any 4 byte number)
	xor $t0, $t0, $t2 # XOR with the initial value
after:
	# Store the new seed value
	sw $t0, rand_seed

	# Return the generated random number
	la $v0, 0($t0)

	# Restore stack and return address
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