
.data
	result: .byte 0
.text
.global main
	.equ X, 0x55AA
	.equ Y, 0xAA55
hamm:
	// r1 = X ^ Y
	eor r1, r1, r0
	//
	movs r3, r1
	and r3, 1
	// r4 = current result
	ldr r2, =result
	adds r2, r2, r3

	bx lr
main:
	ldr r0, =#X //This code will cause assemble error. Why? And how to fix.
	ldr r1, =#Y
	ldr r2, =result
	bl hamm
L: b L
