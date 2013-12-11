# MIPS calculator
# Xulei Ruan A20243302
# CS 402 2013 FALL project


		.data 0x10010000
buffer: .space 60
print_array: .space 80
welcome:         .asciiz "Welcome to Sherry's calculator!"
firstMenu:        .asciiz "\nMIPS Calculator: \n Please choose from\n 1. general calculate \n 2. Extra feature: "
expressionEntry:    .asciiz "\nPlease entry the expression (no more than 5 operands, no '='): "
result_: 	.word 9
secondMenu:	.asciiz "\nPlease choose: 1. decimal to binary 2 decimal to hex 3. hex to binary 4.binary to decimal 5. exit \nYour choice: "
convertNumber:     .asciiz "\nPlease entry the number you want to convert:"
char_0:					.asciiz "0000 "	#decimal 0
char_1:					.asciiz "0001 "	#decimal 1
char_2:					.asciiz "0010 "	#decimal 2
char_3:					.asciiz "0011 "	#decimal 3
char_4:					.asciiz "0100 "	#decimal 4
char_5:					.asciiz "0101 "	#decimal 5
char_6:					.asciiz "0110 "	#decimal 6
char_7:					.asciiz "0111 "	#decimal 7
char_8:					.asciiz "1000 "	#decimal 8
char_9:					.asciiz "1001 " #decimal 9
char_a:					.asciiz "1010 "  #decimal 10 a
char_b:					.asciiz "1011 "  #decimal 11 b
char_c:					.asciiz "1100 " #decimal 12 c
char_d:					.asciiz "1101 " #decimal 13 d
char_e:					.asciiz "1110 " #decimal 14 e
char_f:					.asciiz "1111 " #decimal 15 f
a1: .asciiz "a"
b1: .asciiz "b"
c1: .asciiz "c"
d1: .asciiz "d"
e1: .asciiz "e"
f1: .asciiz "f"
divZeroMessage: .asciiz "Cannot divide by zero."
invalidInput:         .asciiz "\nInvalid input, please try again."
again:		.asciiz "\nDo you want to exit? 1. y 2. n: "



		.text
		.globl main
main:
	addu $s0, $ra, $0	# save $31 in $16
	#Prints out welcome information
	la $a0, welcome         #loads the address of welcome into $a0
	li $v0, 4                #4 is the print_string syscall
	syscall                  #makes the syscall
	li $s1, '+'
	li $s2, '-'
	li $s3, '*'
	li $s4, '/'
	li $t8, '('
	li $t9, ')'
	

	top:
	# get the user's mainMenu input
	la $a0, firstMenu          #loads the address of firstMenu into $a0
	li $v0, 4                 #4 is the print_string syscall
	syscall                   #makes the syscall

	li $v0, 5                 #5 is the syscall for read_int
	syscall                   #makes the syscall and stores the string
	addi $t7, $v0, 0

	addi $t1, $zero, 1        #1 is general calculate
	beq $t7, $t1, general

	addi $t1, $zero, 2        #2 is Extra feature
	beq $t7, $t1, extra

	#If the program gets to here, then the user didn't do it right.
        #Start the program over: 

	la $a0, invalidInput        #loads the address of invalidInput into $a0
	li $v0, 4                   #4 is the print_string syscall
	syscall                     #makes the syscall

	j top                        #Has the user try again with user input. 



general:
	# get the user's input
	la $a0, expressionEntry    #loads the address of expressionEntry into $a0
	li $v0, 4                 #4 is the print_string syscall
	syscall                   #makes the syscall
	li $v0, 8		 # system call for read_String
	la $a0, buffer		#load byte space into address
	syscall	

	add $t1, $0, $0
	add $t3, $0, $0
	add $t5, $0, $0
	
calc:	
	lbu $t0,0($a0)		# $t0 = char[i]
num_or_op:
	beq $t0, 32, jump	# jump over all the spaces
	beq $t0, $t8, op_push
	li $t6,'0' 		# the char in $t0, is it a digit?
	blt $t0, $t6, getNum
	li $t6,'9'
	bgt $t0, $t6, getNum
num:		
	addi $t0,$t0,-48        # change char(ascii number) to int
	li $t6,10
	mul $t5,$t5,$t6		#sum*=10
	add $t5,$t5,$t0		#sum+=array[i]-'0'
	addi $a0, $a0, 1        # i++
	j calc

getNum: 
	sw $t5, print_array($t1);
	addi $t1, $t1, 4
	li $t5, 0
op:
	beq $t3, $0, op_push	
	beq $t0, $s1, Opt_add
	beq $t0, $s2, Opt_min
	beq $t0, $s3, Opt_mul
	beq $t0, $s4, Opt_div
	beq $t0, $t8, op_push
	beq $t0, $t9, Rbracket
	beq $t0, 10, Pop_all 
	la   $a0, invalidInput
	li $v0, 4
	syscall                 #printing invalidInput
	j general
jump:
	addi $a0, $a0, 1        # i++
	j calc
	
Opt_add:
	lw $t2, 0($sp)
	bne $t2, $t8, op_pop
	j op_push

Opt_min:
	lw $t2, 0($sp)
	bne $t2, $t8, op_pop
	j op_push

Opt_mul:
	lw $t2, 0($sp)
	beq $t2, $s1, op_push #Opt_add
	beq $t2, $s2, op_push #Opt_min
	beq $t2, $s3, op_pop
	beq $t2, $s4, op_pop
	la   $a0, invalidInput
	li $v0, 4
	syscall                 #printing invalidInput
	j general

Opt_div:
	lw $t2, 0($sp)
	beq $t2, $s1, op_push #Opt_add
	beq $t2, $s2, op_push #Opt_min
	beq $t2, $s3, op_pop
	beq $t2, $s4, op_pop
	la   $a0, invalidInput
	li $v0, 4
	syscall                 #printing invalidInput
	j general

Rbracket:
	lw $t2, 0($sp)
	bne $t2, $t8, op_pop
	addi $sp, $sp, 4
	addi $t3, $t3, -1
	addi $a0, $a0, 1		# i++
	lbu $t0,0($a0)		# $t0 = char[i]
	beq $t0, 10, Pop_all
	beq $t0, $s1, Opt_add
	beq $t0, $s2, Opt_min
	beq $t0, $s3, Opt_mul
	beq $t0, $s4, Opt_div
	j num_or_op

op_push:
	addi $t3, $t3, 1
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	addi    $a0, $a0, 1             # i++
	j  calc

op_pop:
	lw $t2, 0($sp)
	sw $t2, print_array($t1) 
	addi $sp, $sp, 4
	addi $t1, $t1, 4
	addi $t3, $t3, -1
	j op


Pop_all:
	
	beq $t3, $0, Cal_result
	lw $t2, 0($sp)
	sw $t2, print_array($t1) 
	addi $sp, $sp, 4
	addi $t1, $t1, 4
	addi $t3, $t3, -1
	j Pop_all

Cal_result:
	add $t4, $t1, $0
	add $t1, $0, $0
array_stack:
	beq $t1, $t4, Get_result
	lw $t2, print_array($t1)
	lw $t5, 4($sp)
	lw $t6, 0($sp) 
	beq $t2, $s1, Cal_add
	beq $t2, $s2, Cal_min
	beq $t2, $s3, Cal_mul
	beq $t2, $s4, Cal_div
	j Cal_push

Cal_add:
	add $t7, $t5, $t6
	j Cal_pop

Cal_min:
	sub $t7, $t5, $t6
	j Cal_pop

Cal_mul:
	mult $t5, $t6
	mflo $t7
	j Cal_pop

Cal_div:
	beq $t6, $0, divZero
	div $t5, $t6
	mflo $t7
	j Cal_pop

Cal_pop:
	addi $sp, $sp, 4
	addi $t3, $t3, -1
	addi $t1, $t1, 4
	sw $t7, 0($sp)
	j array_stack

Cal_push:
	addi $t3, $t3, 1
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $t1, $t1, 4
	j array_stack

divZero: 
               #Safely returns the user to the top of the program if they are trying to divide by zero.
	la $a0, divZeroMessage        #loads the address of divZeroMessage into $a0
	li $v0, 4                #4 is the print_string syscall
	syscall                        #makes the syscall

	j general                         #returns to the input stage

Get_result: 
	li $v0, 1       # $system call code for print_double
	lw $a0, 0($sp)       # $integer to print
	syscall
	j againChoice

extra:
	top2:
		
	la $a0, secondMenu          #loads the address of secondMenu into $a0
    li $v0, 4                 #4 is the print_string syscall
    syscall                   #makes the syscall
	li $v0, 5                 #5 is the syscall for read_int
    syscall                   #makes the syscall and stores the string
	addi $t7, $v0, 0

	# get the user's convertNumber input
	la $a0, convertNumber     #loads the address of convertNumber into $a0
    li $v0, 4                 #4 is the print_string syscall
    syscall                   #makes the syscall

	addi $t1, $zero, 1        #1 is decimal to binary
    beq $t7, $t1, decToBin

	addi $t1, $zero, 2        #2 is decimal to hex
	beq $t7, $t1, decToHex

	addi $t1, $zero, 3        #3 is hex to binary
	beq $t7, $t1, hexToBin

	addi $t1, $zero, 4        #4 is binary to decimal
	beq $t7, $t1, binToDec

	addi $t1, $zero, 5        #5 is quit
	beq $t7, $t1, againChoice

	#If the program gets to here, then the user didn't do it right.
	#Start this step over: 

	la $a0, invalidInput        #loads the address of invalidInput into $a0
	li $v0, 4                   #4 is the print_string syscall
	syscall                     #makes the syscall

	j top2                        #Has the user try again with user input. 

decToBin:
	
	li $v0, 5 #read inter command,and put it into v0
	syscall 
	
	move $t1, $v0 	
	addi $t2, $0, 2
dbLoop:
	div $t1, $t2 #Divides $t1 by $t2 and stores the quotient in $LO and the remainder in $HI
	mfhi $t3     #remainder
	mflo $t4		#quotient
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	# sw $ra, 4($sp)
	blt $t1, $t2, DB_print # see if $t1 is smaller than 2, if so, finish and print
	addi $t1, $t4, 0
	jal dbLoop

DB_print:
	
	lw $t0, 0($sp)
	move $a0, $t0
	li $v0, 1		#print int
	syscall
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	addi $t6, $0, 0		
	blt $t0, $t6, againChoice
	addi $t6, $0, 1
	bgt $t0, $t6, againChoice
	j DB_print
	
binToDec:
	li $v0, 8		 # system call for read_String
	la $a0, buffer		#load byte space into address
	syscall	
	addi $t5, $zero,0
read_char:
	lbu $t0,0($a0)		# $t0 = char[i]
	beq $t0, 32, bdjump	# jump over all the spaces
	beq $t0, 10, bdPrint # reach the end of the input string
	li $t6,'0' 		# the char in $t0, is it a '0' or '1'?
	blt $t0, $t6, Error	
	li $t6,'1'
	bgt $t0, $t6, Error
	addi $t0,$t0,-48 
	
mulTwo:	
	addi $t6,$zero,2
	mul $t5,$t5,$t6		#sum*=2
	add $t5,$t5,$t0		#sum+=array[i]-'0'
	addi $a0, $a0, 1        # i++
	j read_char
bdjump:
	addi $a0, $a0,1
	j read_char
bdPrint:
	li	$v0, 1			# load appropriate system call code into register $v0;
						# code for printing integer is 1
	move	$a0, $t5		# move integer to be printed into $a0:  $a0 = $t5
	syscall				# call operating system to perform operation
	j againChoice

decToHex:
	li $v0, 5 # system call for read_int
	syscall
	addu $t1, $v0, $0 #move $v0 to $t1
	addi $t2, $0, 16

DtoH_Div:
	div $t1, $t2 #Divides $t1 by $t2 and stores the quotient in $LO and the remainder in $HI
	mfhi $t3     #remainder
	mflo $t4		#quotient
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	#sw $ra, 4($sp)
	slt $t5, $t1, $t2 # see if $t1 is smaller than 16
	addi $t1, $t4, 0
	beq $t5, 1, DtoH_print # see if $t1 is smaller than 16, if so, finish and print
	jal DtoH_Div

DtoH_print:    #have error somehow
	li $v0, 1
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	addi $t6, $0, 0		
	blt $t0, $t6, againChoice
	addi $t6, $0, 15
	bgt $t0, $t6, againChoice
	slt $t5, $t0, 10
	bne $t5, 1, dhprint
	move $a0, $t0
	syscall
	j DtoH_print
	
dhprint:
	beq $t0, 10, print_a
	beq $t0, 11, print_b
	beq $t0, 12, print_c
	beq $t0, 13, print_d
	beq $t0, 14, print_e
	beq $t0, 15, print_f
print_a:
	li $v0, 4
	la $a0, a1
	syscall
	j DtoH_print
print_b:
	li $v0, 4
	la $a0, b1
	syscall
	j DtoH_print
print_c:
	li $v0, 4
	la $a0, c1
	syscall
	j DtoH_print
print_d:
	li $v0, 4
	la $a0, d1
	syscall
	j DtoH_print
print_e:
	li $v0, 4
	la $a0, e1
	syscall
	j DtoH_print
print_f:
	li $v0, 4
	la $a0, f1
	syscall
	j DtoH_print
	


hexToBin:
	li $v0,8       # system call for read_string
	la $a0, buffer #load byte space into address
	syscall	
	move $s0,$a0	#save string into $s0
read_data:    			
	lbu $t1,0($s0)	#read char at char[i]
	beq $t1,'0',print_char_0
	beq $t1,'1',print_char_1
	beq $t1,'2',print_char_2
	beq $t1,'3',print_char_3
	beq $t1,'4',print_char_4
	beq $t1,'5',print_char_5
	beq $t1,'6',print_char_6
	beq $t1,'7',print_char_7
	beq $t1,'8',print_char_8
	beq $t1,'9',print_char_9
	beq $t1,'a',print_char_a
	beq $t1,'b',print_char_b
	beq $t1,'c',print_char_c
	beq $t1,'d',print_char_d
	beq $t1,'e',print_char_e
	beq $t1,'f',print_char_f
	beq $t1,10,againChoice
						
print_char_0:
	li $v0,   4						
	la $a0, char_0
	syscall
	addi $s0,$s0,1
	j read_data
						
print_char_1:			
	li $v0,  4
	la $a0, char_1
	syscall
	addi $s0,$s0,1
	j read_data
						
print_char_2:			
	li $v0,  4
	la $a0, char_2
	syscall
	addi $s0,$s0,1
	j read_data						
						
print_char_3:			
	li $v0,  4
	la $a0, char_3
	syscall
	addi $s0,$s0,1
	j read_data		

print_char_4:			
	li $v0,  4
	la $a0, char_4
	syscall
	addi $s0,$s0,1
	j read_data		

print_char_5:
	li $v0,  4
	la $a0, char_5
	syscall
	addi $s0,$s0,1
	j read_data							

print_char_6:			
	li $v0,  4
	la $a0, char_6
	syscall
	addi $s0,$s0,1
	j read_data	

print_char_7:			
	li $v0,  4
	la $a0, char_7
	syscall
	addi $s0,$s0,1
	j read_data		
						
print_char_8:			
	li $v0,  4
	la $a0, char_8
	syscall
	addi $s0,$s0,1
	j read_data		

print_char_9:			
	li $v0,  4
	la $a0, char_9
	syscall
	addi $s0,$s0,1
	j read_data		
						
print_char_a:			
	li $v0,  4
	la $a0, char_a
	syscall
	addi $s0,$s0,1
	j read_data
						
print_char_b:			
	li $v0,  4
	la $a0, char_b
	syscall
	addi $s0,$s0,1
	j read_data								
										
print_char_c:			
	li $v0,  4
	la $a0, char_c
	syscall
	addi $s0,$s0,1
	j read_data		
						
print_char_d:			
	li $v0,  4
	la $a0, char_d
	syscall
	addi $s0,$s0,1
	j read_data								

print_char_e:			
	li $v0,  4
	la $a0, char_e
	syscall
	addi $s0,$s0,1
	j read_data	

print_char_f:			
	li $v0,  4
	la $a0, char_f
	syscall
	addi $s0,$s0,1
	j read_data							
						



againChoice:  
	# Ask if user want to exit or run the program again
	top1:
	# get the user's again input
	la $a0, again          #loads the address of again into $a0
        li $v0, 4                 #4 is the print_string syscall
        syscall                   #makes the syscall

	li $v0, 5                 #5 is the syscall for read_int
        syscall                   #makes the syscall and stores the string
        addi $t7, $v0, 0

	addi $t1, $zero, 1        #1 is to exit
        beq $t7, $t1, end

        addi $t1, $zero, 2        #2 is to run this program again
        beq $t7, $t1, top

	#If the program gets to here, then the user didn't do it right.
        #Start the program over: 

        la $a0, invalidInput        #loads the address of invalidInput into $a0
        li $v0, 4                   #4 is the print_string syscall
        syscall                     #makes the syscall

        j top1                        #Has the user try again with user input. 
Error:
	la $a0, invalidInput        #loads the address of invalidInput into $a0
	li $v0, 4                   #4 is the print_string syscall
	syscall                     #makes the syscall

	j secondMenu			 #Has the user try again with user input. 

end:
        addu $ra, $0, $s0 # return address back in $31
	jr $ra # return from main