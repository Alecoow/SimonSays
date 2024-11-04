# Various functions to help with transitioning from C to Assembly
.data
time_struct: 			.space 8

.text
print_message:	
	la $t0, 0($a0) # Take a0 as our temp
	la $a0, 0($t0) # Move our actual a0 into our syscall arugment
	li $v0, 4 # Syscall code for printf
	syscall
	jr $ra

exit_routine:
	li $v0, 10 # Exit
	syscall
	nop

malloc: # void* malloc(int size) takes $a0 as argument, return val goes into $v0
	la $t0, 0($a0) # Take a0 as our temp
	la $a0, 0($t0) # Move our actual a0 into our syscall arugment
	li $v0, 9 # Syscall code for sbrk (heap allocate)
	syscall
	jr $ra

sleep: # sleep(ms)
	la $t0, 0($a0) # Take a0 as our temp
	la $a0, 0($t0) # Move our actual a0 into our syscall arugment
	li $v0, 32 # Syscall code for sleep (ms)
	syscall
	jr $ra

getc: # char getc() ($v0 is our character)
	li $v0, 12 # Syscall code for read character
	syscall
	jr $ra

get_time: # time_struct get_time()
	la $a0, time_struct # Move 8-byte time_struct into a0 (populated by gettime)
	li $v0, 30 # Syscall code for get time
	syscall
	jr $ra

rand:
	jal get_time
	la $t1, time_struct
	la $t0, 4($t1) # Seed with the first for bytes of time_struct

	andi $t1, $t0, 1 # Get the least significant bit
	srl $t0, $t0, 1 # Shift right by 1
	beqz $t1, after # If LSB is 0, skip XOR
	li $t2, 0xB400 # Load initial value (Any 4 byte number)
	xor $t0, $t0, $t2 # XOR with the initial value
after:
	# Store the new seed value
	sw $t0, rand_seed

	# Return the generated random number
	la $v0, $t0
	jr $ra
