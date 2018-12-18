@ armlab2.s
@    CS 413L
@    Timothy Couch
@    19 September 2017
@
@ Run a soft drink machine
@
@ To assemble, link, and run the program:
@   as -o armlab2.o armlab2.s
@   gcc -o armlab2 armlab2.o
@   ./armlab2

.data
@setup vars
stack: .space 2000, 0		@gimme 500 words
newLine: .asciz "\n"

@soft drink amounts
numCoke: .word 5
numSprite: .word 5
numDrPepper: .word 5
numDietCoke: .word 5
numMellowYellow: .word 5

@input character space
charIn: .word 0

@drink name strings
strCoke: .asciz "Coke"
strSprite: .asciz "Sprite"
strDrPepper: .asciz "Dr. Pepper"
strDietCoke: .asciz "Diet Coke"
strMellowYellow: .asciz "Mellow Yellow"

@welcome message
strWelcome: .asciz "Welcome to TJ's soft drink vending machine.\nCost of Coke, Sprite, Dr. Pepper, Diet Coke, and Mellow Yellow is 55 cents.\n\nPlease insert a penny (P), nickel (N), dime (D), quarter (Q), half-dollar (F), slug (S), or dollar bill (B). Press return (R) to return change or quit.\n"

@prompt to enter a coin letter
strCoinPrompt: .asciz "Enter coin or select return."

@strings that tell total or respond to other coin inputs
strTotal: .asciz "Total is %d cents. "						@dont println
strNoSlugs: .asciz "No slugs! "								@dont println
strReturned: .asciz "%d cents returned. "					@dont println
strInputError: .asciz "Sorry, but that is not a choice. "	@dont println
strExit: .asciz "Goodbye!"

@prompt to choose a drink
strDrinkPrompt: .asciz "Make selection or return: (C) Coke, (S) Sprite, (P) Dr. Pepper, (D) Diet Coke, or (M) Mellow Yellow"

@string that tells drink and remaining total
strDrinkPurchase: .asciz "Thank you for purchasing a %s. You have %d cents left."

@string that tells the drink is out
strDrinkOut: .asciz "Sorry, but we are out of %ss."

@input string for a character
strCharInput: .asciz "%c%*c"
.align 4

@Program-------------------------------------------------
.text
.global main

main:
		@set up stack
		LDR sp, =stack
		ADD sp, sp, #2000
		
		@set up registers for values
		MOV r4, #0					@r4 = money in machine
		
		@print welcome
		LDR r0, =strWelcome
		BL println
		
		@ask for coins, accept coins
		readCoins:
			LDR r0, =strCoinPrompt
			BL println
			
			@read coin input
			LDR r0, =strCharInput
			LDR r1, =charIn
			BL scan
			
			@handle coin input
			LDR r0, [r1]			@r0 = char input
			BL takeCoin
			
			@if sum less than price for drinks, loop back and ask to enter coins
			CMP r4, #55
			BLT readCoins
			
			@if sum greater than price for drinks, give drink
			readDrinks:
				@print drink prompt asking to make selection or return
				LDR r0, =strDrinkPrompt
				BL println
				
				@read drink input
				LDR r0, =strCharInput
				LDR r1, =charIn
				BL scan
				
				@handle drink input
				LDR r0, [r1]		@r0 = char input
				BL takeDrink
				
				@if returning to coin prompt, return to coin prompt
				CMP r0, #1
				BEQ readCoins
				
				@return to drink prompt if enough change
				CMP r4, #55
				BGE readDrinks
				
				@otherwise, return to coin prompt
				B readCoins
				
endProgram: @end program
		LDR r0, =strExit
		BL println
		
		MOV r7, #1
		SVC 0


@Subroutines---------------------------------------------

@ bool takeDrink: gives the drink and subtracts money or returns to coin input
@	r0: char of drink input
@	r4: money
@	RETURNS r0: 0 if continuing normally or 1 if returning to coin prompt
@	fun fact: nice Communion pun
takeDrink:
	PUSH {r1-r3, lr}
	
	@purchase the drink or return
	
	@purchase this drink or check the next one
	takeDrink_Coke:
		@move on to the next drink if not this drink
		CMP r0, #'C'
		BNE takeDrink_Sprite
		
		@if out of drinks, print so
		LDR r1, =numCoke
		LDR r1, [r1]
		CMP r1, #0
		LDRLE r1, =strCoke
		BLE takeDrink_out
		
		@if not out of drinks, detract drink price
		SUB r4, r4, #55
		
		@remove one drink
		SUB r1, r1, #1
		LDR r2, =numCoke
		STR r1, [r2]
		
		@print purchase drink
		LDR r1, =strCoke
		B takeDrink_purchase
	
	@purchase this drink or check the next one
	takeDrink_Sprite:
		@move on to the next drink if not this drink
		CMP r0, #'S'
		BNE takeDrink_DrPepper
		
		@if out of drinks, print so
		LDR r1, =numSprite
		LDR r1, [r1]
		CMP r1, #0
		LDRLE r1, =strSprite
		BLE takeDrink_out
		
		@if not out of drinks, detract drink price
		SUB r4, r4, #55
		
		@remove one drink
		SUB r1, r1, #1
		LDR r2, =numSprite
		STR r1, [r2]
		
		@print purchase drink
		LDR r1, =strSprite
		B takeDrink_purchase
	
	@purchase this drink or check the next one
	takeDrink_DrPepper:
		@move on to the next drink if not this drink
		CMP r0, #'P'
		BNE takeDrink_DietCoke
		
		@if out of drinks, print so
		LDR r1, =numDrPepper
		LDR r1, [r1]
		CMP r1, #0
		LDRLE r1, =strDrPepper
		BLE takeDrink_out
		
		@if not out of drinks, detract drink price
		SUB r4, r4, #55
		
		@remove one drink
		SUB r1, r1, #1
		LDR r2, =numDrPepper
		STR r1, [r2]
		
		@print purchase drink
		LDR r1, =strDrPepper
		B takeDrink_purchase
	
	@purchase this drink or check the next one
	takeDrink_DietCoke:
		@move on to the next drink if not this drink
		CMP r0, #'D'
		BNE takeDrink_MellowYellow
		
		@if out of drinks, print so
		LDR r1, =numDietCoke
		LDR r1, [r1]
		CMP r1, #0
		LDRLE r1, =strDietCoke
		BLE takeDrink_out
		
		@if not out of drinks, detract drink price
		SUB r4, r4, #55
		
		@remove one drink
		SUB r1, r1, #1
		LDR r2, =numDietCoke
		STR r1, [r2]
		
		@print purchase drink
		LDR r1, =strDietCoke
		B takeDrink_purchase
	
	@purchase this drink or check the next one
	takeDrink_MellowYellow:
		@move on to the next drink if not this drink
		CMP r0, #'M'
		BNE takeDrink_Return
		
		@if out of drinks, print so
		LDR r1, =numMellowYellow
		LDR r1, [r1]
		CMP r1, #0
		LDRLE r1, =strMellowYellow
		BLE takeDrink_out
		
		@if not out of drinks, detract drink price
		SUB r4, r4, #55
		
		@remove one drink
		SUB r1, r1, #1
		LDR r2, =numMellowYellow
		STR r1, [r2]
		
		@print purchase drink
		LDR r1, =strMellowYellow
		B takeDrink_purchase
		
	@return to coin prompt - MUST BE LAST in this switch statement
	takeDrink_Return:
		@if not equal to R, print that it is an input error
		CMP r0, #'R'
		BNE takeDrink_unrec
		
		@if R, return to coin prompt
		MOV r0, #1
		B takeDrink_return
	
	@prints that the drink is out. r1 = address of drink name
	takeDrink_out:
		LDR r0, =strDrinkOut
		@LDR r1, =strDrinkName
		BL println
		MOV r0, #0
		B takeDrink_return
	
	@prints purchase string. r1 = address of drink name
	takeDrink_purchase:
		LDR r0, =strDrinkPurchase
		@LDR r1, =strDrinkName
		MOV r2, r4
		BL println
		
		MOV r0, #0
		B takeDrink_return
	
	@print unrecognized input, return
	takeDrink_unrec:
		LDR r0, =strInputError
		BL print
		
		MOV r0, #0
		B takeDrink_return
		
	@just return
	takeDrink_return:
		POP {r1-r3, pc}

@ void takeCoin: adds the coin input to the money or returns money
@	r0: char of coin input
@	r4: money
takeCoin:
	PUSH {r0-r3, lr}
	
	@adds coin value to money
	CMP r0, #'P'
	ADDEQ r4, r4, #1
	BEQ takeCoin_added
	
	CMP r0, #'N'
	ADDEQ r4, r4, #5
	BEQ takeCoin_added
	
	CMP r0, #'D'
	ADDEQ r4, r4, #10
	BEQ takeCoin_added
	
	CMP r0, #'Q'
	ADDEQ r4, r4, #25
	BEQ takeCoin_added
	
	CMP r0, #'F'
	ADDEQ r4, r4, #50
	BEQ takeCoin_added
	
	CMP r0, #'B'
	ADDEQ r4, r4, #100
	BEQ takeCoin_added
	
	CMP r0, #'S'
	LDREQ r0, =strNoSlugs
	BLEQ print
	BEQ takeCoin_return
	
	@return change - MUST BE LAST in this switch statement
	@if not equal to R, print that it is an input error
	CMP r0, #'R'
	BNE takeCoin_unrec
	
	@if there is no money in the machine, quit the program
	CMP r4, #0
	BEQ endProgram
	
	@if theres money in the machine, return it
	LDR r0, =strReturned
	MOV r1, r4
	BL print
	MOV r4, #0
	B takeCoin_return
	
	@print total and return
	takeCoin_added:
		LDR r0, =strTotal
		MOV r1, r4
		BL print
		
		B takeCoin_return
	
	@print unrecognized input, return
	takeCoin_unrec:
		LDR r0, =strInputError
		BL print
		
		B takeCoin_return
	
	@just return
	takeCoin_return:
		POP {r0-r3, pc}

@ void print: Prints a string with specified format
@   r0: address of formatted string
@   r1: first formatted value to print
@   r2: second formatted value to print
@   r3: third(?) formatted value to print
print:
	PUSH {r0-r3, lr}
	
	BL printf
	
	POP {r0-r3, pc}

@ void println: Prints a string with specified format and a new line
@   r0: address of formatted string
@   r1: first formatted value to print
@   r2: second formatted value to print
@   r3: third(?) formatted value to print
println:
	PUSH {r0-r3, lr}
	
	BL printf			@not BL print to preserve stack space
	BL printNewLine
	
	POP {r0-r3, pc}

@ void printNewLine: Prints a new line
printNewLine:
	PUSH {r0-r3, lr}
	
	LDR r0, =newLine
	BL printf
	
	POP {r0-r3, pc}

@ void scan: Reads a value with specified format
@   r0: address of format string
@   r1: address in which to store the value read
scan:
	PUSH {r0-r3, lr}
	
	BL scanf
	
	POP {r0-r3, pc}
