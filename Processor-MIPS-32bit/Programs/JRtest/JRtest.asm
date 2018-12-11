main:
li $ra, 8
j other

li $v0, 1
li $a0, 1
syscall
li $v0, 10
syscall

other:
jr $ra


