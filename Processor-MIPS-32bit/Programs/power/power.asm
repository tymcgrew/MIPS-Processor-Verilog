main:
li $t0, 0 # base
li $t1, 0 # power
li $t2, 0 # counter
li $t3, 0 # result
li $t4, 0 # mult counter
li $t5, 0 # mult result

li $v0, 5  
syscall             
move $t0, $v0 

li $v0, 5 
syscall             
move $t1, $v0 

beq $t1, $zero, zero  # if (power == 0) go to zero case
 
li $t6, 1
beq $t1, $t6, one     # if (power == 1) go to one case

bltz $t1, zero        # if (power < 0) go to zero case

setup:
li $t2, 1
move $t3, $t0             

pow:
beq $t2, $t1, exit
li $t4, 0      # mult counter
li $t5, 0      # mult result
jal mult
move $t3, $t5
addiu $t2, $t2, 1
j pow

mult:
bltz $t0, multneg

multpos:
beq $t4, $t0, multdone
addu $t5, $t5, $t3
addiu $t4, $t4, 1
j multpos

multneg:
beq $t4, $t0, multdone
subu $t5, $t5, $t3
addiu $t4, $t4, -1
j multneg

multdone:
jr $ra

zero:
li $t3, 1
j exit

one:
move $t3, $t0
j exit

exit:
move $a0, $t3
li $v0, 1 
syscall 

li $v0, 10 
syscall 
