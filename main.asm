# A Simon Says game, with a twist
# Written by Alex Cooper
.data
press_any_key:			.asciiz "\nPress any key to exit...\n"
welcome:				.asciiz "Welcome to Simon Says! How far can you get in 5 minutes?\n"
time_up:				.asciiz "Time's up!\n"
event_start:			.asciiz "Event Started: "
d_o_n:					.asciiz "Double or Nothing\n"
e_l:					.asciiz "Extra Life\n"
score_multiplier:		.word 	1
s_m:					.asciiz "Score Multiplier\n"
l_r:					.asciiz "Lightning Round\n"
prompt:					.asciiz "Enter the sequence, separated by commas:\n"
correct_answer:			.asciiz "Good job! Moving to level "
wrong_answer:			.asciiz "Incorrect! Repeating level "
invalid_answer:			.asciiz "Invalid character(s)! Try again\n"
final_score:			.asciiz "Final Score: "
new_line:				.asciiz "\n"
dimensions:				.word	1
level:					.word 	1
score: 					.word 	0
difficulty: 			.word 	0
rows: 					.word 	1
columns: 				.word 	1

.text

.globl print_message
.globl exit
.globl malloc
.globl sleep
.globl getc
.globl main
.globl time
.globl rand
.globl ClearConsole
.globl AllocateArray
.globl tests

main:
	la $a0, welcome
	jal print_message # printf("Welcome ...")

	jal tests	

	la $a0, 2500
	jal sleep # sleep(2500)
	
	jal ClearConsole
	
	j loop

loop:
	# do stuff
	

	la $a0, press_any_key
	jal print_message # printf("Press any key to exit...)
	jal getc # get input
	bne $v0, $0, exit # jump to exit if getc() != 0

	b loop

tests:
	# malloc test
	# $s0 malloc(8)
	# Push stack (save 4 bytes for return address)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $a0, 8 # Request an int
	jal malloc # Call malloc
	lw $ra, 0($sp)
	and $s0, $v0, $v0 # Save allocated memory address in $s0
	# print_int(999900)
	li $t0, 999900
	sw $t0, 4($s0)
	lw $a0, 4($s0)
	jal print_int
	lw $ra, 0($sp)
	la $a0, new_line
	jal print_message
	lw $ra, 0($sp)
	# Test if we actually have malloc working by splitting the int
	# print_int(990000)
	li $t0, 990000
	sw $t0, 0($s0)
	lw $a0, 0($s0)
	jal print_int
	lw $ra, 0($sp)
	la $a0, new_line
	jal print_message
	lw $ra, 0($sp)
	# free(s0, 8)
	la $a0, ($s0)
	li $a1, 8
	jal free	
	lw $ra, 0($sp)
	# rand test
	# rand()
	jal rand
	lw $ra, 0($sp)
	#print_int(v0)
	la $a0, ($v0)
	jal print_int
	lw $ra, 0($sp)
	la $a0, new_line
	jal print_message
	lw $ra, 0($sp)
	# Pop stack
	addi $sp, $sp, 4
	# return
	jr $ra

# By default, MARS does not begin execution at "main" (though this can be changed in the settings), so any includes are put at the bottom
.include "util.asm"
.include "helpers.asm"
