
#2.4. USING SYSCALL: ADD2.ASM 25
# $v0 - syscall parameter.
main:

li $v0, 5
syscall
move $t0, $v0

li $v0, 5
syscall
move $t1, $v0

addu $t2, $t0, $t1

li $v0, 1
move $a0, $t2
syscall

li $v0, 10 
syscall