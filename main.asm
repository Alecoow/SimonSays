# A Simon Says game, with a twist
# Written by Alex Cooper
.data
buffer: .space 100
time_up_msg: .asciiz "Time's up!\n"
enter_sequence_msg: .asciiz "Enter the sequence, separated by commas:\n"
good_job_msg: .asciiz "Good job! Moving to level %i\n"
incorrect_msg: .asciiz "Incorrect! Repeating level %i\n"
invalid_chars_msg: .asciiz "Invalid character(s)! Try again\n"
final_score_msg: .asciiz "Final Score: %d\n"
number_format: .asciiz "%i  "
newline: .asciiz "\n"
flattened_array: .space 400  # Adjust size as needed

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
    li $s0, 1      # difficulty = 1
    li $s1, 1      # dimensions = initial value
    li $s3, 0      # score = 0
    li $s4, 1      # level = 1
    li $s5, 1      # score_multiplier = 1
    li $s6, 1      # time_multiplier = 1

difficulty_loop:
    blt $s0, 6, difficulty_loop_body
    b end_game  # Exit loop when difficulty >= 6

difficulty_loop_body:
    # Check if difficulty % 5 == 0
    li $t1, 5
    rem $t2, $s0, $t1
    bne $t2, $zero, skip_dimension_increment
    addi $s1, $s1, 1   # dimensions++
    li $s0, 1          # difficulty = 1

skip_dimension_increment:
    # Allocate simon_numbers
    move $a0, $s1     # dimensions
    move $a1, $s0     # difficulty
    jal AllocateArray
    move $s2, $v0     # simon_numbers

    # Populate simon_numbers
    move $a0, $s1     # dimensions
    move $a1, $s0     # difficulty
    move $a2, $s2     # simon_numbers
    jal PopulateList

    # Display simon_numbers
    li $t0, 0         # i = 0
display_outer_loop:
    bge $t0, $s1, display_outer_end

    # Load simon_numbers[i]
    mul $t1, $t0, 4
    add $t2, $s2, $t1
    lw $t3, 0($t2)    # simon_numbers[i]

    li $t4, 0         # j = 0
display_inner_loop:
    bge $t4, $s0, display_inner_end

    # Print simon_numbers[i][j]
    mul $t5, $t4, 4
    add $t6, $t3, $t5
    lw $t7, 0($t6)    # simon_numbers[i][j]

    move $a0, $t7
    li $v0, 1         # print_int syscall
    syscall

    la $a0, newline
    jal print_message

    addi $t4, $t4, 1  # j++
    j display_inner_loop

display_inner_end:
    addi $t0, $t0, 1  # i++
    j display_outer_loop

display_outer_end:
    # Flatten the array
    move $a0, $s2     # simon_numbers
    move $a1, $s1     # dimensions
    move $a2, $s0     # difficulty
    la $a3, flattened_array
    jal FlattenArray

    # Free simon_numbers
    move $a0, $s2     # simon_numbers
    move $a1, $s1     # dimensions
    jal FreeArray

    # Clear console
    jal ClearConsole

    # Prompt user for input
	la $a0, enter_sequence_msg
	jal print_message

    # Read user input
    la $a0, buffer
    li $a1, 100
    li $v0, 8         # read_string syscall
    syscall

    # Compare answer
    la $a0, buffer
    la $a1, flattened_array
    mul $a2, $s1, $s0 # dimensions * difficulty
    jal CompareAnswer
    move $t8, $v0     # result

    # Process result
    li $t9, 1
    beq $t8, $t9, correct_answer
    li $t9, 0
    beq $t8, $t9, incorrect_answer
    j invalid_answer

correct_answer:
    # Good job message
    addi $s4, $s4, 1   # level++
    move $a0, $s4
    li $v0, 1          # print_int syscall
    syscall
    la $a0, good_job_msg
    jal print_message

    # Update score
    addi $s3, $s3, 1   # score++
    mul $s3, $s3, $s5  # score *= score_multiplier
    j update_end

incorrect_answer:
    # Incorrect message
	move $a0, $s4	# Integer to print
	jal print_int
    la $a0, incorrect_msg
	jal print_message

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
    # Clear console
    jal ClearConsole

    # Reset score_multiplier
    li $s5, 1

    # Increase difficulty
    addi $s0, $s0, 1
    j difficulty_loop

end_game:
    # Final score message
    move $a0, $s3      # score
    li $v0, 1          # print_int syscall
    syscall
    la $a0, final_score_msg
	jal print_message

	jal exit

# FlattenArray function
FlattenArray:
    # Arguments:
    # $a0 - simon_numbers
    # $a1 - dimensions
    # $a2 - difficulty
    # $a3 - flattened_array

    # Save registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    move $s0, $a0     # simon_numbers
    move $s1, $a1     # dimensions
    move $s2, $a2     # difficulty
    move $t0, $a3     # flattened_array pointer

    li $t1, 0         # i = 0

flatten_outer_loop:
    bge $t1, $s1, flatten_end

    # Load simon_numbers[i]
    mul $t2, $t1, 4
    add $t3, $s0, $t2
    lw $t4, 0($t3)    # simon_numbers[i]

    li $t5, 0         # j = 0
flatten_inner_loop:
    bge $t5, $s2, flatten_inner_end

    # Load simon_numbers[i][j]
    mul $t6, $t5, 4
    add $t7, $t4, $t6
    lw $t8, 0($t7)

    # Store into flattened_array
    sw $t8, 0($t0)
    addi $t0, $t0, 4  # Move to next position

    addi $t5, $t5, 1  # j++
    j flatten_inner_loop

flatten_inner_end:
    addi $t1, $t1, 1  # i++
    j flatten_outer_loop

flatten_end:
    # Restore registers
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

# CompareAnswer function
CompareAnswer:
    # Arguments:
    # $a0 - buffer (user input)
    # $a1 - flattened_array
    # $a2 - length (dimensions * difficulty)

    # Save registers
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    move $s0, $a2     # length
    li $t0, 0         # index = 0
    li $t1, 0         # input index = 0

compare_loop:
    bge $t0, $s0, compare_success   # If all elements matched, success

    lb $t2, 0($a0)    # Load next character
    beq $t2, $zero, compare_failure # End of string before expected

    # Skip commas and whitespace
    beq $t2, ',', skip_char
    beq $t2, ' ', skip_char

    # Convert char to int
    subi $t2, $t2, 48
    blt $t2, 0, compare_invalid     # Not a digit
    bgt $t2, 9, compare_invalid     # Not a digit

    # Load expected number
    lw $t3, 0($a1)
    beq $t2, $t3, match_number
    j compare_failure

match_number:
    addi $a1, $a1, 4   # Move to next expected number
    addi $t0, $t0, 1   # index++
    j skip_char

skip_char:
    addi $a0, $a0, 1   # input index++
    j compare_loop

compare_success:
    li $v0, 1          # Return 1 for correct
    j compare_exit

compare_failure:
    li $v0, 0          # Return 0 for incorrect
    j compare_exit

compare_invalid:
    li $v0, -1         # Return -1 for invalid input

compare_exit:
    # Restore registers
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

.include "util.asm"
.include "helpers.asm"
