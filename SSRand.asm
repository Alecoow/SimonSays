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