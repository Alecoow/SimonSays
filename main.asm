# Simon Says
# By Alex Cooper

.data
	
	.globl main
	.globl exit
	.globl game_loop
	.globl get_time
	.globl rand
	.globl draw
	.globl no_xor
	
	frameBuffer: .space 0x80000
	rand_seed: .word 0
	welcome: .asciiz "Welcome to Simon Says! How far can you get in 5 minutes?\n"
	time_up: .asciiz "Time's up!\n"
	event_start: .asciiz "Event Started: "
	d_o_n: .asciiz "Double or Nothing\n"
	e_l: .asciiz "Extra Life\n"
	score_multiplier: .word 1
	s_m: .asciiz "Score Multiplier\n"
	l_r: .asciiz "Lightning Round\n"
	prompt: .asciiz "Enter the sequence, separated by commas:\n"
	correct_answer: .asciiz "Good job! Moving to level "
	wrong_answer: .asciiz "Incorrect! Repeating level "
	invalid_answer: .asciiz "Invalid character(s)! Try again\n"
	final_score: .asciiz "Final Score: "
	new_line: .asciiz "\n"
	level: .word 1
	score: .word 0
	difficulty: .word 0
	rows: .word 1
	columns: .word 1
	time_struct: .space 8
	array: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	
.text
main:
	# Print welcome
	la $a0, welcome
	li $v0, 4 # print as string
	syscall
	
	jal rand
	move $a0, $v0 # $a0 now holds random number
	li $v0, 36 # print as unsigned int
	syscall
	
	#draw rectangle
	#jal draw
	
	# start game
	#jal game_loop
	j exit

game_loop:
	addi $sp, $sp, -4
	sw $ra, 0($sp) # save main
	
	# do stuff
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra # return to main

get_time:
	la $a0, time_struct
	li $v0, $v0, 30
	syscall
	jr $ra

rand:
	jal get_time
	lw $s0, 4(time_struct) # seed with time value

	andi $s1, $s0, 1      # Get the least significant bit
	srl $s0, $s0, 1       # Shift right by 1
	beqz $s1, no_xor      # If LSB is 0, skip XOR
	li $t2, 0xB400        # Load the tap value (0xB400 for 16-bit LFSR)
	xor $t0, $t0, $t2     # XOR with the tap value
no_xor:
	# Store the new seed value
	sw $s0, rand_seed

	# Return the generated random number
	move $v0, $s0
	jr $ra
	
draw:
	li $a0,100	# left x-coordinate is 100
	li $a1,25	# width is 25
	li $a2,200	# top y-coordinate is 200
	li $a3,50	# height is 50
	
	addi $sp, $sp -4 # store $ra to stack
	sw $ra, 0($sp)
	
	jal rectangle
	
	lw $ra, 0($sp) # restore $ra
	addi $sp, $sp, 4
	
	jr $ra


exit:
	li $v0, 10
	syscall
	
