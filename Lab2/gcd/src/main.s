	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	result: .word 0
	max_size: .word 0
.text
	m: .word 0x5E
	n: .word 0x60
GCD:
	//TODO: Implement your GCD function
	// r4=a, r5=b, r6=return value
	LDR r4, [MSP]
	ADDS r7, MSP, 4
	LDR r5, [r7]
	// whether a or b = 0
	CMP r4, 0
	BEQ return_b
	CMP r5, 0
	BEQ return_a
	// even or odd
	ANDS r7, r4, 1
	ANDS r8, r5, 1
	CMP r7, 1
	BNE even_a
	CMP r8, 1
	BNE even_b
	// a, b are odd
	SUBS r7, r4, r5
	CMP r7, 0
	BLT
	even_a:
		CMP r8, 1
		BNE even_ab
	even_b:

	even_ab:

	return_b:
		MOVS r6, r5
		POP
		POP
		SUBS r3, r3, 2
	return_a:
		MOVS r6, r4
main:
	// r0 = m, r1 = n, r2 = max_size, r3 = current_size
	LDR r0, =m
	LDR r1, =n
	PUSH {r0, r1}
	MOVS r2, 2
	MOVS r3, 2
	B GCD
	// get return val and store into result
over:
	B over
