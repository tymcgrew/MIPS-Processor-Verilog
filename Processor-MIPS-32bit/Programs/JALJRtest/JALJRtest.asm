main:

li $t0, 1
jal extra
li $v0, 1
move $a0, $t0
syscall
li $v0, 10
syscall

extra:
addiu $t0, $t0, 1
jr $ra
