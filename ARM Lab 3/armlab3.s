@ armlab3.s
@    CS 413L
@    Timothy Couch
@    10 October 2017
@
@ Copies data from one memory location to another
@	Store some data (strings) in each memory addresses
@	Print both memory addresses and contents
@	Read source_address, dest_address, length from console
@		if either address incorrect or length too long, error
@	Copy data from source to dest with specified length
@	Print both memory addresses and contents
@	
@ To assemble, link, and run the program:
@   as -o armlab3.o armlab3.s
@   gcc -o armlab3 armlab3.o
@   ./armlab3

.data
@setup vars
stack: .space 2000, 0		@gimme 500 words
newLine: .asciz "\n"

@first memory location
mem1: .space 200, 49		@199-length string max (null terminated). Fill with 1
strMem1Store: .asciz "Hello. This is the data in memory location 1."
strMem1: .asciz "Memory Block 1 Address: %d\nMemory Block 1 Contents:"	@requires an int input

@second memory location
mem2: .space 200, 50		@199-length string max (null terminated). Fill with 2
strMem2Store: .asciz "Hi. This string is in memory location 2."
strMem2: .asciz "Memory Block 2 Address: %d\nMemory Block 2 Contents:"	@requires an int input

memSize: .word 200			@size of memory chunks (max length to copy)

@input strings
strSourcePrompt: .asciz "Please enter the source memory address: "			@dont println
strDestPrompt: .asciz "Please enter the destination memory address: "		@dont println
strLengthPrompt: .asciz "Please enter the number of bytes to copy: "		@dont println
strIntInput: .asciz " %d"
intIn: .word 0

@error strings
strSourceError: .asciz "Error: Please enter a valid source address (Enter address 1 or 2)."
strDestError: .asciz "Error: Please enter a valid destination address (Enter address 1 or 2)."
strLengthError: .asciz "Error: Please enter a valid number of bytes to copy (0 < n <= 200)."

.align 4

@Program-------------------------------------------------
.text
.global main

main:
	@set up stack
	LDR sp, =stack
	ADD sp, sp, #2000
	
	@set up registers for values
	
	@r0 param/return
	@r1 param
	@r2 param
	@r3 param
	@
	@r4 address of memory 1
	@r5 address of memory 2
	@r6 size of memory chunks (max length)
	@
	@r7 address of source
	@r8 address of dest
	@r9 length of data to read
	
	LDR r4, =mem1
	LDR r5, =mem2
	LDR r6, =memSize
	LDR r6, [r6]
	
	@set up memory locations with data
	BL initMemory
	
printAddresses:	@print memory addresses and contents		
		LDR r0, =strMem1
		MOV r1, r4
		BL println
		MOV r0, r4
		BL println
		
		LDR r0, =strMem2
		MOV r1, r5
		BL println
		MOV r0, r5
		BL println
	
readAddresses: @read addresses and length
		@read source address
		LDR r0, =strSourcePrompt
		BL print
		
		LDR r0, =strIntInput
		LDR r1, =intIn
		BL scan
		
		LDR r7, [r1]
		
		@read dest address
		LDR r0, =strDestPrompt
		BL print
		
		LDR r0, =strIntInput
		LDR r1, =intIn
		BL scan
		
		LDR r8, [r1]
		
		@read length
		LDR r0, =strLengthPrompt
		BL print
		
		LDR r0, =strIntInput
		LDR r1, =intIn
		BL scan
		
		LDR r9, [r1]
	
	@copy data source to dest with specified length, errors built in
		MOV r0, r7
		MOV r1, r8
		MOV r2, r6
		MOV r3, r9
		MOV r10, #1
		BL copyBlock
	
	@print addresses (loop up) or read if error
		CMP r0, #1
		BGE printAddresses
		B readAddresses
	
endProgram: @end program
	MOV r7, #1
	SVC 0

@Subroutines---------------------------------------------

@ void initMemory: Puts strings in memory 1 and 2
initMemory:
	PUSH {r0-r3, lr}
	
	MOV r0, r4
	LDR r1, =strMem1Store
	MOV r2, r6
	BL initMemoryBlock
	
	MOV r0, r5
	LDR r1, =strMem2Store
	MOV r2, r6
	BL initMemoryBlock
	
	POP {r0-r3, pc}

@ void initMemoryBlock: Puts string in supplied memory block and null terminates the end
@	r0: address of memory block
@	r1: address of string to put in
@	r2: length of memory block
initMemoryBlock:
	PUSH {r0-r4, r10, lr}
	
	@r4 = address of memory block
	MOV r4, r0
	
	@get length of string
	MOV r0, r1
	BL stringLength
	
	@copy string into memory - use copyBlock
	@r3 = length of string, length to copy
	MOV r3, r0
	@r2 = (already done) memory block length
	@r0 = source address (string address)
	MOV r0, r1
	@r1 = destination address (memory block address)
	MOV r1, r4
	@r10 = 0 (dont error if not memory block 1 or 2)
	MOV r10, #0
	BL copyBlock
	
	@null terminate memory
	@r1 = final address of data
	ADD r1, r1, r2
	SUB r1, r1, #1
	@r0 = null terminator (0)
	MOV r0, #0
	STRB r0, [r1]	@put a null terminator in the last position
	
	POP {r0-r4, r10, pc}

@ bool copyBlock: Copies from one block into another with specified length if able. Prints error messages otherwise
@	returns to r0: whether or not it succeeded (0 = error, 1 = success)
@	r0: source address
@	r1: destination address
@	r2: length of memory block (of both)
@	r3: length of data to copy
@	r10: whether to error when seeing memory block 1 or 2 (0 = dont, 1 = do)
copyBlock:
	PUSH {r1-r4, lr}
	
	@if r3 greater than r2, error
	CMP r3, r2
	LDRGT r0, =strLengthError
	BLGT println
	MOVGT r0, #0
	BGT copyBlock_end
	
	@if not checking for memory blocks 1 and 2, skip
	CMP r10, #1
	BLT copyBlock_DestCorrect
	
	@if source not one of the two memory addresses, error
	CMP r0, r4
	BEQ copyBlock_SourceCorrect
	CMP r0, r5
	BEQ copyBlock_SourceCorrect
	LDR r0, =strSourceError
	BL println
	MOV r0, #0
	B copyBlock_end
	
	copyBlock_SourceCorrect:
		@if dest not one of the two memory addresses, error
		CMP r1, r4
		BEQ copyBlock_DestCorrect
		CMP r1, r5
		BEQ copyBlock_DestCorrect
		LDR r0, =strDestError
		BL println
		MOV r0, #0
		B copyBlock_end
	
	copyBlock_DestCorrect:	@done checking for errors, now copy stuff
		@r4 = current offset
		MOV r4, #0
	
	copyBlock_copyPos:
		@r2 = byte from source to copy to dest
		LDRB r2, [r0, r4]
		STRB r2, [r1, r4]
		ADD r4, r4, #1	@increment offset
		CMP r4, r3
		BLT copyBlock_copyPos
	@r0 = 1 success
	MOV r0, #1
	
	copyBlock_end:
		POP {r1-r4, pc}

@ int stringLength: Returns the length of a string NOT INCLUDING NULL TERMINATOR
@	returns to r0: length of string
@	r0: address of string
stringLength:
	PUSH {r1-r3, lr}
	
	@r1 = address of character to read
	@r0 = length of string
	MOV r1, r0
	MOV r0, #-1
	
	stringLength_getChar:
		@get character value at current position, increment position
		LDRB r2, [r1], #1
		@length += 1
		ADD r0, r0, #1
		@get character again if current position not null terminator (0)
		CMP r2, #0
		BNE stringLength_getChar
	
	@return r0, length of string
	POP {r1-r3, pc}

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
	
	BL printf
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
