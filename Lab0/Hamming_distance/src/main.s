.data
	result: .byte 0
.text
	.global main
	.equ X, 0x55AA
	.equ Y, 0xAA55
hamm:
	//TODO
	bx lr
main:
	movs r0, #X //This code will cause assemble error. Why? And how to fix.
	movs r1, #Y
	ldr R2, =result
	bl hamm
L: b L