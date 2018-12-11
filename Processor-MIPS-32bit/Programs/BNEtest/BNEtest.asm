main:
li $t0, 1
li $t1, 2

bne $t0, $t1, exit
j main

exit:
li $v0, 1
li $a0, 12
syscall
li $v0, 10
syscall