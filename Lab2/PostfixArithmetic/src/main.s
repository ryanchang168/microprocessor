	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	user_stack: .zero 128
	expr_result:.word 0
.text
	.global main
	postfix_expr: .asciz "-100 10 20 + - 10 + "
main:
	// R0 points to the string ; R1 is counter for loop postfix_expr ; R4 is constants 10 for MUL
	LDR R0, =postfix_expr
	MOVS R1, -1
	MOVS R4, 10
	//TODO: Setup stack pointer to end of user_stack and calculate the expression using PUSH, POP operators, and store the result into expr_result
	// let MSP to end of user_stack
	LDR R7, =user_stack
	ADDS R7, 128
	MSR MSP, R7
	B atoi
	atoi_done:
		PUSH {R2}
		B check
	// plus
	plus:
		ADDS R1, R1, 1
		POP {R8}
		POP {R9}
		ADDS R9, R9, R8
		PUSH {R9}
		B check
	// minus
	minus:
		ADDS R1, R1, 1
		POP {R8}
		POP {R9}
		SUBS R9, R9, R8
		PUSH {R9}
		B check
	check:
		ADDS R2, R0, R1
		LDRB R2, [R2]
		CMP R2, 0
		BEQ done
		ADDS R2, R1, 1
		ADDS R2, R2, R0
		LDRB R2, [R2]
		CMP R2, 0x20
		BEQ done
		B atoi
	done:
		LDR R8, =expr_result
		POP {R9}
		STRB r9, [R8]
program_end:
	B program_end
atoi:
	//TODO: implement a ¡§convert string to integer¡¨ function
	// The input value is R0, while the return value is R2
	// initialize the return value R2, and R5 for negative integer
	MOVS R2, 0
	MOVS R5, 0
	loop:
		// get the byte wanting to check
		ADDS R1, R1, 1
		ADDS R3, R0, R1
		LDRB R3, [R3]
		// check if the end of string -> space -> negative integer reg -> negative operator -> positive operator
		CMP R3, 0
		BEQ done
		CMP R3, 0x20
		BEQ atoi_done
		CMP R5, 1
		BEQ negative
		CMP R3, 0x2d
		BEQ negative
		CMP R3, 0x2b
		BEQ plus
		// positive integer
		positive:
			MULS R2, R2, R4
			SUBS R9, R3, 0x30
			ADDS R2, R2, R9
			B loop
		// negative integer
		negative:
			// set R5 reg
			MOVS R5, 1
			// see whether negative operator, if so, then see whether the next is space
			CMP R3, 0x2d
			BEQ negative_op
			// calculate minus and store in R2
			MULS R2, R2, R4
			SUBS R9, R3, 0x30
			SUBS R2, R2, R9
			B loop
		negative_op:
			ADDS R8, R1, 1
			ADDS R6, R0, R8
			LDRB R6, [R6]
			CMP R6, 0x20
			BEQ minus
			CMP R6, 0x2d
			BEQ minus
			B loop
