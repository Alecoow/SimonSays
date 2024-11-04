# A Simon Says game, with a twist
# Written by Alex Cooper
.data
press_any_key:			.asciiz "\nPress any key to exit...\n"
rand_seed:				.word 	0
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
.globl exit_routine
.globl malloc
.globl sleep
.globl getc
.globl main
.globl get_time
.globl rand
.globl ClearConsole
.globl AllocateArray

main:
	la $a0, welcome
	jal print_message # printf("Welcome ...")

	la $a0, 2500
	jal sleep # sleep(2500)
	
	jal ClearConsole
	
	j loop

loop:
	# do stuff
	

	la $a0, press_any_key
	jal print_message # printf("Press any key to exit...)
	jal getc # get input
	bne $v0, $0, exit_routine # jump to exit if getc() != 0

	b loop

# By default, MARS does not begin execution at "main" (though this can be changed in the settings), so any includes are put at the bottom
.include "util.asm"
.include "helpers.asm"
