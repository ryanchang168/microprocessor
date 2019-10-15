.syntax unified
.cpu cortex-m4
.thumb

.data
	result: .word 0
	max_size: .word 0
.text
	m: .word 0x5E
	n: .word 0x60
	.global main
main:
	ldr r0,m
	ldr r1,n
	mov r6,#0  //max size
	push {r0,r1}
	bl GCD
	ldr r0,=result
	ldr r1,=max_size
	str r5,[r0]
	str r6,[r1]
L: B L

GCD:
	cmp r0,#0
	beq m_zero
	cmp r1,#0
	beq n_zero
	cmp r0,r1
	beq m_zero
	and r2,r0,#1
	and r3,r1,#1
	orr r4,r2,r3
	cmp r4,#0
	beq both_even
	cmp r2,#0
	beq m_even
	cmp r3,#0
	beq n_even
	b both_odd

m_zero:
	mov r5,r1
	BX LR
n_zero:
	mov r5,r0
	BX LR
m_even:
	push {r0,r1,LR}
	add r6,#3
	lsr r0,#1
	bl GCD
	pop {LR,r1,r0}
	BX LR
n_even:
	push {r0,r1,LR}
	add r6,#3
	lsr r1,#1
	bl GCD
	pop {LR,r1,r0}
	BX LR
both_even:
	push {r0,r1,LR}
	add r6,#3
	lsr r0,#1
	lsr r1,#1
	bl GCD
	lsl r5,#1
	pop {LR,r1,r0}
	BX LR
both_odd:
	push {r0,r1,LR}
	add r6,#3
	cmp r0,r1
	blt swap
	sub r0,r0,r1
	bl GCD
	pop {LR,r1,r0}
	BX LR
swap:
	sub r7,r1,r0
	mov r1,r0
	mov r0,r7
	bl GCD
	pop {LR,r1,r0}
	BX LR
