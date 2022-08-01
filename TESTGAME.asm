# Names : Clowie Garcia, Amy Mendiola, Raahul Sugumar, & Esha Tadi
# Class : CS2340.001, Professor Nguyen
# Date  : December 07, 2021
# Program Description: "The Mind Reader" Program prompts the user to
#	 think of a number within the range of 1 to 63. It displays 
#	 cards containing a set of various numbers, asking the user to
#	 accept or deny if their number is contained in the card set
#	 After the user enters their response (Y/N) for each card, the
#	 program will determine the number that the user was thinking of.

# ------------------- .data segment ------------------- 
.data
	promptUser: .asciiz "Think of a number between 1 and 63. 6 cards will be displayed and after the last card, your number will be revealed!\n"
	responsePrompt: .asciiz "Is your number shown in this card? (Y/N) "
	validPrompt: .asciiz "Please input a valid input (\"Y\" or \"N\")\n "
	displayNum: .asciiz "Your Number Was:"
	againPrompt: .asciiz "Do you want to play again? (Y/N)\n"
	card: .asciiz "Card "
	
	response: .space 1
	cardbit:  .word 32
	maxNum:   .word 63
	num:      .word 0
	
	firstCard:  .word 0
	secondCard: .word 0
	thirdCard:  .word 0
	fourthCard: .word 0
	fifthCard:  .word 0
	sixthCard:  .word 0
	firstCardBit:  .word 0
	secondCardBit: .word 0
	thirdCardBit:  .word 0
	fourthCardBit: .word 0
	fifthCardBit:  .word 0
	sixthCardBit:  .word 0
	
	answer: .word 0
	yes:	.asciiz "Y"
	no: 	.asciiz "N"
	
	space: .asciiz " "
	enter: .asciiz "\n"
	
# Sound for the game
	soundInst:     .byte 57
	soundVol:      .byte 100
	soundPitch:    .byte 69
	soundDuration: .byte 100

# Macro for new line
.macro enter
	li $v0, 4
	la $a0, enter
	syscall
.end_macro 

# Macro for displaying text
.macro display_text(%x)
	li $v0, 4
	la $a0, %x
	syscall
.end_macro 

# Macro for printing
.macro print (%x)
	li $t3, 0
	lw $t2, %x
Loop:
	bgt  $t3, 63,  End
	addi $t3, $t3, 1
	and  $t1, $t2, $t3
	bne  $t1, $t2, Loop
	sw   $t3, num
	li   $v0, 1
	move $a0, $t3
	syscall
	li   $v0, 4
	la   $a0, space
	syscall
	j    Loop
End:
.end_macro 

# Macro for setting card bit
.macro setCardBit(%x)
	lw  $t2, %x
	sub $t2, $t2, 1
	li  $t3, 2
	li  $t4, 1
Loop:
	ble  $t2, 0, End
	mult $t4, $t3
	mflo $t4
	sub  $t2, $t2, 1
	j Loop
End:
	display_text(card)
	lw   $t2, %x
	li   $v0, 1
	move $a0, $t2
	syscall
	enter
.end_macro 

# Macro for calculating user's number
.macro process_response(%x, %y)
	lb  $t1, %y
	lb  $t3, no
	lb  $t4, yes
	lb  $t2, 0(%x)
	beq $t2, $t3, End
	beq $t2, $t4, Add
	j End
Add:
	lw  $t5, answer
	add $t5, $t5, $t1
	sw  $t5, answer
End:
.end_macro  

# Macro to validate user input
.macro input_validity(%x)
	lb $t2, 0(%x)
	j Check
reAsk:
	display_text(validPrompt)
	li   $v0, 8
	la   $a0, response
	li   $a1, 20
	move $t0, $a0
	syscall
	lb   $t2, 0($t0)
	j Check
Check:
	lb  $t3, no
	lb  $t4, yes
	beq $t2, $t3 ,End
	beq $t2, $t4 ,End
	j reAsk
	
End:
.end_macro 

# Macro for playing sound
.macro play_sound
	li   $v0, 31
	la   $t0, soundPitch
	la   $t1, soundDuration 
	la   $t2, soundInst
	la   $t3, soundVol
	move $a0, $t0 
	move $a1, $t1 
	move $a2, $t2
	move $a3, $t3 
	syscall
.end_macro

# Macro for reading user input
.macro read_response(%x)
	li   $v0, 8
	la   $a0, %x
	li   $a1, 20
	move $t0, $a0
    	syscall
.end_macro

# ------------------- .text segment -------------------
.text
Game:
	display_text(promptUser)
	
Loop:
	#Generate card order randomly--------------------------
	li  $a1, 6		# $a1 is the max bound.
    	li  $v0, 42		# Generates the random number.
    	syscall
    	add $a0, $a0, 1	        # lowest bound

    	#checks if random number has already been assigned
#if is has been generate new number
    	lw  $t0, firstCard
	lw  $t1, secondCard
	lw  $t2, thirdCard
	lw  $t3, fourthCard
	lw  $t4, fifthCard
	lw  $t5, sixthCard
    	beq $a0, $t0, Loop
    	beq $a0, $t1, Loop
    	beq $a0, $t2, Loop
    	beq $a0, $t3, Loop
    	beq $a0, $t4, Loop
    	beq $a0, $t5, Loop
    	
	
Continue:
#set card number
    	beq $zero, $t0, setFirst
    	beq $zero, $t1, setSecond
    	beq $zero, $t2, setThird
    	beq $zero, $t3, setFourth
    	beq $zero, $t4, setFifth
    	beq $zero, $t5, setSixth
    	
setFirst:
    	sw $a0, firstCard
    	j Loop
    
setSecond:
    	sw $a0, secondCard
    	j Loop
    	
setThird:
    	sw $a0, thirdCard
  	j Loop
    	
setFourth:
    	sw $a0, fourthCard
    	j Loop
    
setFifth:
    	sw $a0, fifthCard
    	j Loop

setSixth:
    	sw $a0, sixthCard
    	lw $t2, sixthCard
    	syscall
  	
  	# Prints the first card -------------------------------------
  	enter
    	setCardBit(firstCard)
    	sw $t4, firstCardBit 
    	print(firstCardBit)
    	enter
    	
    	# Asks if user's number is in card; reads their input 
	display_text(responsePrompt)
	enter
	read_response(response)
    	enter
    	
    	# Plays sound
    	play_sound
	
	# Determines if user response is valid 
    	la $t0, response
    	input_validity($t0)
    	
    	# Calculating user's number
    	process_response($t0, firstCardBit)
    	
    	# Prints the second card -------------------------------------
    	setCardBit(secondCard)
    	sw $t4, secondCardBit 
    	print(secondCardBit)
    	enter
    	
    	# Asks if user's number is in card; reads their input
	display_text(responsePrompt)
	enter
	read_response(response)
    	enter
    	
    	# Plays sound
    	play_sound 
	
	# Determines if user response is valid
	la $t0, response
    	input_validity($t0)
    	
    	# Calculating user's number
    	process_response($t0, secondCardBit)
    	
    	# Prints the third card -------------------------------------
    	setCardBit(thirdCard)
    	sw $t4, thirdCardBit 
    	print(thirdCardBit)
    	enter
    	
    	# Asks if user's number is in card; reads their input
    	display_text(responsePrompt)
	enter
	read_response(response)
    	
    	# Plays sound
    	play_sound
	
	# Determines if user response is valid
    	la $t0, response
    	input_validity($t0)
    	
    	# Calculating user's number
    	process_response($t0, thirdCardBit)
    	
    	# Prints the fourth card -------------------------------------
    	enter
	setCardBit(fourthCard)
    	sw $t4, fourthCardBit 
    	print(fourthCardBit)
    	enter
    	
    	# Asks if user's number is in card; reads their input
    	display_text(responsePrompt)
	enter
	read_response(response)
    	
    	# Plays sound
	play_sound
	
	# Determines if user response is valid
	la $t0, response
    	input_validity($t0)
    	
    	# Calculating user's number
    	process_response($t0, fourthCardBit)
    	
    	# Prints the fifth card -------------------------------------
    	enter
    	setCardBit(fifthCard)
    	sw $t4, fifthCardBit 
    	print(fifthCardBit)
    	enter
    	
    	# Asks if user's number is in card; reads their input
    	display_text(responsePrompt)
	enter
	read_response(response)
    	
    	# Plays sound
    	play_sound 
	
	# Determines if user response is valid
	la $t0, response
    	input_validity($t0)
    	
    	# Calculating user's number
    	process_response($t0, fifthCardBit)
    	
    	# Prints the sixth card -------------------------------------
    	enter
    	setCardBit(sixthCard)
    	sw $t4, sixthCardBit 
    	print(sixthCardBit)
    	enter
    	
    	# Asks if user's number is in card; reads their input
    	display_text(responsePrompt)
	enter
	read_response(response)
    	
    	# Plays sound
    	play_sound
	
	# Determines if user response is valid
	la $t0, response
    	input_validity($t0)
    	
    	# Calculating user's number
    	process_response($t0, sixthCardBit)
    	
# Displays the user's number
	enter
	display_text(displayNum)
	enter
	li $v0, 1
	lw $a0, answer
	syscall
	enter
	enter
	
# Plays the program again
	# Prompts user if they want to play again; read user input
	display_text(againPrompt)
	read_response(response)
	
	# Validates user response
    	la $t0, response
    	input_validity($t0)
    	
    	# Determines whether user wants to re-run or end program
	lb $t3, no
	lb $t4, yes
	lb $t2, 0($t0)
	beq $t2, $t3, End
	beq $t2, $t4, Restart
	
# Restarts the program
Restart:
	sw $zero, firstCard
	sw $zero, secondCard
	sw $zero, thirdCard
	sw $zero, fourthCard
	sw $zero, fifthCard
	sw $zero, sixthCard
	sw $zero, answer
	j Game

# Ends the program
End:
	li $v0, 10              
    	syscall
