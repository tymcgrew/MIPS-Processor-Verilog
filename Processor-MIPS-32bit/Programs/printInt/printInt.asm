# print an integer
main:
## Print out $t2. 
addi $a0, $zero, 3 # move the number to print into $a0.
addi $v0, $zero, 1 # load syscall print_int into $v0.
syscall # make the syscall.

addi $v0, $zero, 10 # syscall code 10 is for exit.
syscall # make the syscall.