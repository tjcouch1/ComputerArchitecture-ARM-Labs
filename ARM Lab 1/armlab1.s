@ armlab1.s
@    CS 413L
@    Timothy Couch
@    6 September 2017
@ Print and sum even numbers, then print the sum.
@ Print and sum odd numbers, then print the sum.
@ Print sum of the two.
@ For this example, we are reading a value in as a string,
@ and writing it as a string, so no conversion is necessary.
@ To assemble, link, and run the program:
@   as -o armlab1.o armlab1.s
@   ld -o armlab1 armlab1.o
@   ./armlab1

.text
.global _start

_start:
	@ set up stack
	LDR sp, =stack
	ADD sp, sp, #100
	
	@ print evens text
	LDR r1, =evenStr
	LDR r0, =evenStrLength
	LDR r2, [r0]
	BL println
	
	@print and sum evens
	MOV r5, #2			@ r5 is the index in the loop
	MOV r3, #0			@ r3 is the sum of the evens
	
	loopEvens:
		@print r5 number
		MOV r1, r5
		BL outDec
		BL printNewLine
		
		ADD r3, r3, r5		@ add number to sum
		
		ADD r5, r5, #2		@ add two to the index
		CMP r5, #25
		BLE loopEvens
	
	@print sum of evens
	LDR r1, =evenSumStr
	LDR r0, =evenSumStrLength
	LDR r2, [r0]
	BL print
	@print r3 number
		MOV r1, r3
		BL outDec
		BL printNewLine
	
	
	@ print odds text
	LDR r1, =oddStr
	LDR r0, =oddStrLength
	LDR r2, [r0]
	BL println
	
	@print and sum odds
	MOV r5, #1			@ r5 is the index in the loop
	MOV r4, #0			@ r4 is the sum of the odds
	
	loopOdds:
		@print r5 number
		MOV r1, r5
		BL outDec
		BL printNewLine
		
		ADD r4, r4, r5		@ add number to sum
		
		ADD r5, r5, #2		@ add two to the index
		CMP r5, #25
		BLE loopOdds
	
	@print sum of evens
	LDR r1, =oddSumStr
	LDR r0, =oddSumStrLength
	LDR r2, [r0]
	BL print
	@print r4 number
		MOV r1, r4
		BL outDec
		BL printNewLine
	
	@total the sums
	MOV r5, #0			@clear r5 - total of even and odd
	ADD r5, r3, r4
	
	@print total
	LDR r1, =totalSumStr
	LDR r0, =totalSumStrLength
	LDR r2, [r0]
	BL print
	@print r5 number
	MOV r1, r5
	BL outDec
	BL printNewLine

endProgram: @ end the program
	MOV r7, #1
	SVC 0


outDec:   @ This routine expects the number to be printed to be in r1 before being called
          PUSH  {r0-r4, r6, r8, lr}     @ save working registers & link register
          MOV   r8, #0
          MOV   r4, #0                  @ number of digits in number to print
outNext:  
          MOV   r8, r8, LSL #4
          ADD   r4, r4, #1
          BL    div10                   @ quotient will be in r1 and remainder in r2
          ADD   r8, r8, r2              @ insert remainder (least significant digit)
          CMP   r1, #0                  @ if quotient zero then all done
          BNE   outNext                 @ else deal with the next digit
outNxt1:  AND   r0, r8, #0xF
          ADD   r0, r0, #0x30
          LDR   r6, =value
          STR   r0, [r6]                @ copy value in r0 to our storage area (value)
          MOVS  r8, r8, LSR #4
          BL    putCh
          SUBS  r4, r4, #1              @ decrement counter
          BNE   outNxt1                 @ repeat until all printed          
outEx:    POP {r0-r4, r6, r8, pc}       @ restore registers and return

div10:                                  @ divide r1 by 10
                                        @ return with quotient in r1, remainder in r2      
          SUB   r2, r1, #10
          SUB   r1, r1, r1, LSR #2
          ADD   r1, r1, r1, LSR #4
          ADD   r1, r1, r1, LSR #8
          ADD   r1, r1, r1, LSR #16
          MOV   r1, r1, LSR #3
          ADD   r3, r1, r1, ASL #2
          SUBS  r2, r2, r3, ASL #1
          ADDPL r1, r1, #1
          ADDMI r2, r2, #10
          MOV   pc, lr                  @ exit div10 and return

putCh:    
          PUSH {r0-r2, r7, lr}          @ save working registers

          @ write the value
          MOV   r7, #4                  @ doing a write
          MOV   r0, #1                  @ file descriptor for standard output
          LDR   r1, =value              @ address of character to print
          MOV   r2, #1                  @ buffer size of 1 (writing 1 char)
          SVC   0                       @ invoke kernel (do system call)

          POP {r0-r2, r7, pc}           @ exit putCh and return

print: @ prints dereferenced r1 with length r2
	PUSH {r0-r2, r7, lr}		@ store on stack
	
	MOV r0, #1			@ stdout
	MOV r7, #4			@ indicate write
	@r1 - address of string
	@r2 - length to print
	SVC 0				@ call system print!
	
	POP {r0-r2, r7, pc}		@ get from stack

println: @ prints dereferenced r1 with length r2 and a new line
	
	PUSH {r0-r2, r7, lr}		@ store on stack
	
	BL print
	BL printNewLine
	
	POP {r0-r2, r7, pc}		@ get from stack

printNewLine: @ prints a \n
	
	PUSH {r0-r2, r7, lr}		@ store on stack
	
	MOV r0, #1			@ stdout
	MOV r7, #4			@ doing a print
	LDR r1, =newline		@ put \n into r1
	MOV r2, #1			@ indicate string is 1 char long
	SVC 0				@ print!
	
	POP {r0-r2, r7, pc}		@ get from stack

.data

evenStr: .asciz "Evens 1 to 25: "
evenStrLength: .word 16
evenSumStr: .asciz "Sum of Evens: "
evenSumStrLength: .word 14

oddStr: .asciz "Odds 1 to 25: "
oddStrLength: .word 15
oddSumStr: .asciz "Sum of Odds: "
oddSumStrLength: .word 13

totalSumStr: .asciz "Sum of Evens and Odds 1 to 25: "
totalSumStrLength: .word 31

value:  .word 0                 @ place to store value

newline: .ascii "\n"

stack: .space 100, 0
