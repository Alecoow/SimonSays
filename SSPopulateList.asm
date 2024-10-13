.text
.globl PopulateList

PopulateList:
    # Set up stack frame
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    # Load arguments
    lw $s0, 16($sp)  # dimensions
    lw $s1, 20($sp)  # size
    lw $t0, 24($sp)  # list (pointer to array of pointers)

    # Outer loop (i loop)
    move $t1, $zero  # i = 0
outer_loop:
    bge $t1, $s0, end_outer_loop  # if i >= dimensions, exit outer loop

    # Load the pointer to the current row
    sll $t2, $t1, 2  # t2 = i * 4 (size of int*)
    add $t3, $t0, $t2  # t3 = list + (i * 4)
    lw $t4, 0($t3)  # t4 = list[i]

    # Inner loop (j loop)
    move $t5, $zero  # j = 0
inner_loop:
    bge $t5, $s1, end_inner_loop  # if j >= size, exit inner loop

    # Generate random number
    jal rand
    move $t6, $v0  # t6 = rand() % 10
    li $t7, 10
    rem $t6, $t6, $t7

    # Store the random number in the array
    sll $t8, $t5, 2  # t8 = j * 4 (size of int)
    add $t9, $t4, $t8  # t9 = list[i] + (j * 4)
    sw $t6, 0($t9)  # list[i][j] = t6

    # Increment j
    addi $t5, $t5, 1
    j inner_loop
end_inner_loop:

    # Increment i
    addi $t1, $t1, 1
    j outer_loop
end_outer_loop:

    # Restore stack frame and return
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra