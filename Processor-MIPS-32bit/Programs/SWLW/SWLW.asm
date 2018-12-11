main:
li $a0, 0
li $t0, 7
sw $t0, 20
lw $a0, 20

li $v0, 1
syscall

li $v0, 10
syscall
