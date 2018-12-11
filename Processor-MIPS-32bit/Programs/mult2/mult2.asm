main:
li $t3, 0             #t3 = counter
li $t2, 0             #t2 = num

li $v0, 5  
syscall             
move $t0, $v0         #t0 = firstinput

li $v0, 5  
syscall             
move $t1, $v0         #t1 = secondinput

bltz $t1 neg

pos:			# for (int t3 = 0; t3 < secondinput; t3++)
beq $t3, $t1, exit 	# if (t3 == secondinput) exit loop
addu $t2, $t2, $t0      # num += firstinput
addiu $t3, $t3, 1 	# t3 = counter += 1
j pos

neg:
beq $t3, $t1, exit
subu $t2, $t2, $t0
addiu $t3, $t3, -1
j neg

exit:
move $a0, $t2 
li $v0, 1 
syscall 

li $v0, 10 
syscall 
