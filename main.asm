# A Simon Says game, with a twist
# Written by Alex Cooper
.data
buffer:             .space 100
time_up_msg:        .asciiz "Time's up!\n"
enter_sequence_msg: .asciiz "Enter the sequence, separated by commas:\n"
good_job_msg:       .asciiz "Good job! Moving to level "
incorrect_msg:      .asciiz "Incorrect! Repeating level "
invalid_chars_msg:  .asciiz "Invalid character(s)! Try again\n"
final_score_msg:    .asciiz "Final Score: %d\n"
newline:            .asciiz "\n"
space:              .asciiz ", "
.align 4
flattened_array:    .space 400 # Adjust size as needed

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

main:
    # Initialize variables
    li $s0, 1 # difficulty = 1
    li $s1, 1 # dimensions = initial value
    li $s3, 0 # score = 0
    li $s4, 1 # level = 1
    li $s5, 1 # score_multiplier = 1
    li $s6, 1 # time_multiplier = 1 

difficulty_loop:
    blt $s0, 6, difficulty_loop_body
    b end_game # Exit loop when difficulty >= 6

difficulty_loop_body:
    # Check if difficulty % 5 == 0
    li $t1, 5
    rem $t2, $s0, $t1
    bne $t2, $zero, skip_dimension_increment
    addi $s1, $s1, 1 # dimensions++
    li $s0, 1 # difficulty = 1

skip_dimension_increment:
    # Allocate simon_numbers
    move $a0, $s1 # dimensions
    move $a1, $s0 # difficulty
    jal AllocateArray
    move $s2, $v0 # simon_numbers
    
    # Populate simon_numbers
    move $a0, $s1 # dimensions
    move $a1, $s0 # difficulty
    move $a2, $s2 # simon_numbers
    jal PopulateList    
    
    # Display simon_numbers
    li $t0, 0 # i = 0

display_outer_loop:
    bge $t0, $s1, display_outer_end 

    # Load simon_numbers[i]
    mul $t1, $t0, 4
    add $t2, $s2, $t1
    lw $t3, 0($t2) # simon_numbers[i]   
    
    li $t4, 0 # j = 0

display_inner_loop:
    bge $t4, $s0, display_inner_end

    # Print simon_numbers[i][j]
    mul $t5, $t4, 4
    add $t6, $t3, $t5
    lw $t7, 0($t6) # simon_numbers[i][j]

    move $a0, $t7
    jal print_int
    
    li $a0, 500 # sleep(500ms)
    jal sleep

    la $a0, space
    jal print_message

    addi $t4, $t4, 1 # j++
    j display_inner_loop

display_inner_end:
    la $a0, newline
    jal print_message

    addi $t0, $t0, 1 # i++
    j display_outer_loop

display_outer_end:
    # Flatten the array
    move $a0, $s2 # simon_numbers
    move $a1, $s1 # dimensions
    move $a2, $s0 # difficulty
    la $a3, flattened_array
    jal FlattenArray

    # Free simon_numbers
    move $a0, $s2 # simon_numbers
    move $a1, $s1 # dimensions
    jal FreeArray

    li $a0, 2000
    jal sleep
    
    # Clear console
    jal ClearConsole

    # Prompt user for input
    la $a0, enter_sequence_msg
    jal print_message

    # Read user input
    la $a0, buffer
    li $a1, 100
    li $v0, 8 # read_string syscall
    syscall

    # Compare answer
    la $a0, buffer
    la $a1, flattened_array
    mul $a2, $s1, $s0 # dimensions * difficulty
    jal CompareAnswer
    move $t8, $v0 # result

    # Process result
    li $t9, 1
    beq $t8, $t9, correct_answer
    li $t9, 0
    beq $t8, $t9, incorrect_answer
    j invalid_answer

correct_answer:
    addi $s4, $s4, 1 # level++
    # Good job!
    la $a0, good_job_msg
    jal print_message    
    move $a0, $s4
    jal print_int

    # Update score
    addi $s3, $s3, 1 # score++
    mul $s3, $s3, $s5 # score *= score_multiplier
    j update_end

incorrect_answer:
    # Incorrect message
    
    la $a0, incorrect_msg # "Incorrect! Repeating level %i"
    jal print_message
    move $a0, $s4 # Integer to print
    jal print_int

    # Decrease difficulty
    addi $s0, $s0, -1

    # Update score
    li $t0, 1
    mul $t0, $t0, $s5
    sub $s3, $s3, $t0
    j update_end

invalid_answer:
    # Invalid input message
    la $a0, invalid_chars_msg
    jal print_message

    # Decrease difficulty
    addi $s0, $s0, -1

update_end:

    li $a0, 2000 # sleep(2000)
    jal sleep
    
    # Clear console
    jal ClearConsole

    # Reset score_multiplier
    li $s5, 1

    # Increase difficulty
    addi $s0, $s0, 1
    j difficulty_loop

end_game:
    # Final score message
    move $a0, $s3 # score
    li $v0, 1 # print_int syscall
    syscall
    la $a0, final_score_msg
    jal print_message

    jal exit

.include "util.asm"
.include "helpers.asm"
