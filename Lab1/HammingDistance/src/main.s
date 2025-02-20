.syntax unified
.cpu cortex-m4
.thumb

.data
	result: .byte 0
	XYxor: .word
.text
.global main
	.equ X, 0x1234
	.equ Y, 0x4567
rotate_bits:
	// do "and gate" to determine whether to add 1
	ldr r2, =XYxor
	ldr r1, [r2]
	cmp r1, 0
	beq end_hamm
	movs r2, #1
	and r1, r1, r2
	// add and store the value to result
	ldr r2, =result
	ldrb r3, [r2]
	add r3, r3, r1
	strb r3, [r2]
	// divide XYxor by 2 then loop to rotate_bits
	ldr r2, =XYxor
	ldr r1, [r2]
	lsr r1, 1
	str r1, [r2]
	b rotate_bits
hamm:
	// XYxor = X ^ Y and it should be divided to 0 at last to calculate hamming distance
	eor r1, r1, r0
	ldr r2, =XYxor
	str r1, [r2]
	bl rotate_bits
	end_hamm:
		b L
main:
	ldr r0, =#X //This code will cause assemble error. Why? And how to fix.
	ldr r1, =#Y
	ldr r2, =result
	bl hamm
L: b L
