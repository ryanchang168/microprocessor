	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	X: .word 5
	Y: .word 10
	Z: .word
.text
.global main
	.equ AA, 0x55
main:
	ldr r0, =X
	ldr r1, [r0]
	ldr r0, =Y
	ldr r2, [r0]
	mul r3, r1, r2
	ldr r0, =Z
	str r3, [r0]
L: B L
