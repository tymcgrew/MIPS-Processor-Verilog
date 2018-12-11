main:
li $t0, 2              # t0 = current num
loop:

li $t2, 2              # t2 = i (outer counter)
outerLoop:
beq $t0, $t2, print

li $t3, 2              # t3 = j (inner counter)
innerLoop:
beq $t0, $t3, doneInner

li $t4, 0              # t4 = mulitplication counter
li $t5, 0              # t5 = multiplication result
jal mult
beq $t5, $t0, done

addiu $t3, $t3, 1
j innerLoop
doneInner:

addiu $t2, $t2, 1
j outerLoop
doneOuter:

j loop

mult:
beq $t4, $t3, doneMult
addu $t5, $t5, $t2
addiu $t4, $t4, 1
j mult
doneMult:
jr $ra

print:
move $a0, $t0
li $v0, 1
syscall

done:
addiu $t0, $t0, 1
j loop
