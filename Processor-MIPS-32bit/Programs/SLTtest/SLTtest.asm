main:

li $t0, 1
li $t1, 2
slt $t2, $t0, $t1

move $a0, $t2
li $v0, 1
syscall
li $v0, 10
syscall