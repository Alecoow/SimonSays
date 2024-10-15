# Simon Says
# By Alex Cooper

.include "SSPopulateList.asm"

.data
	array: .space 16  # Allocate space for 2D Array[2][2] (4 integers * 4 bytes)
	rand_seed: .word 0

.text
	.globl main

main:
    # Set up stack frame
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    # Initialize dimensions and size
    li $s0, 2  # dimensions = 2
    li $s1, 2  # size = 2

    # Load the base address of the array
    la $t0, array

    # Call PopulateList
    addi $a0, $s0, 0  # dimensions
    addi $a1, $s1, 0  # size
    addi $a2, $t0, 0  # list (pointer to array)
    jal PopulateList

    # Print the 2D array
    li $t1, 0  # i = 0
print_outer_loop:
    bge $t1, $s0, end_print_outer_loop  # if i >= dimensions, exit outer loop

    li $t2, 0  # j = 0
print_inner_loop:
    bge $t2, $s1, end_print_inner_loop  # if j >= size, exit inner loop

    # Calculate the address of array[i][j]
    sll $t3, $t1, 2  # t3 = i * 4 (size of int*)
    add $t4, $t0, $t3  # t4 = array + (i * 4)
    sll $t5, $t2, 2  # t5 = j * 4 (size of int)
    add $t6, $t4, $t5  # t6 = array[i] + (j * 4)

    # Load and print the value
    lw $a0, 0($t6)
    li $v0, 1  # syscall for print integer
    syscall

    # Print a space
    li $a0, ' '
    li $v0, 11  # syscall for print character
    syscall

    # Increment j
    addi $t2, $t2, 1
    j print_inner_loop
end_print_inner_loop:

    # Print a newline
    li $a0, '\n'
    li $v0, 11  # syscall for print character
    syscall

    # Increment i
    addi $t1, $t1, 1
    j print_outer_loop
end_print_outer_loop:

    # Restore stack frame and return
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra












# Create random number
rand:
    lw $t0, rand_seed
    li $t1, 1103515245
    mul $t0, $t0, $t1
    li $t1, 12345
    add $t0, $t0, $t1
    sw $t0, rand_seed
    srl $v0, $t0, 16
    jr $ra
