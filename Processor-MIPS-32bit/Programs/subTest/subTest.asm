main:

li $t3, -5

li $a0, 4
bltz $t3, done 

li $a0, 3

done:
li $v0, 1
syscall

li $v0, 10 
syscall
