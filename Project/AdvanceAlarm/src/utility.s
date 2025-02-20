.syntax unified
.cpu cortex-m4
.thumb

.text
	.global gpio_init
	.global test
	.global fpu_enable
	.equ RCC_AHB2ENR,  0x4002104C
	.equ RCC_APB2ENR,  0x40021060

	.equ GPIOA_BASE,   0x48000000
	.equ BSRR_OFFSET,  0x18 @ set bit
	.equ BRR_OFFSET,   0x28 @ clear bit

	.equ GPIOB_BASE,   0x48000400
	.equ GPIOB_PUPDR,  0x4800040C
	.equ GPIOB_SPEEDER,0x48000408

	.equ GPIOC_BASE,   0x48000800
	.equ GPIOC_PUPDR,  0x4800080C
	.equ GPIOC_SPEEDER,0x48000808

	.equ AFRL_OFFSET,  0x20
	.equ AFRH_OFFSET,  0x24

	.equ GPIOC_BASE,   0x48000800

test:
	push {lr}
 	mov r0, r0
 	mov r1, r1
 	mov r2, r2
 	mov r3, r3
 	pop {pc}


gpio_init:
	push {r0, r1, r2, lr}

	mov  r0, 0b00000000000000000000000000000111 //GPIOA B C
	ldr  r1, =RCC_AHB2ENR
	ldr  r2, =#RCC_AHB2ENR
	orr  r0, r2
	str  r0, [r1]

	ldr  r1, =GPIOB_BASE // GPIOB_MODER
	ldr  r2, [r1]
	ldr  r3, =0b11111111111111111100000000000000
	and  r2, r3 // PB5 output, PB4 input, PB6 input, PB2 input, PB1 output, PB0 input, PB3 alternate function mode
	ldr  r3, =0b00000000000000000000010010000100
	orr  r2, r3
	str  r2, [r1]

	ldr r1,=GPIOB_PUPDR
	ldr r2, [r1]
	ldr r3,  =0b11111111111111111100000000000000
	and r2, r3 // PB6 & PB5 & PB4 & PB3 & PB2 & PB1 & PB0 pull-up
	ldr r3,  =0b00000000000000000001010101010101
	orr r2, r3
	str r2, [r1]

	ldr  r1, =GPIOB_SPEEDER
	ldr  r2, [r1]
	ldr  r3, =0b11111111111111111100000000000000
	and  r2, r3 //50MHz
	ldr  r3, =0b00000000000000000010101010101010
	orr  r2, r3
	str  r2, [r1]

	pop  {r0, r1, r2, pc}

fpu_enable:
	push  {r0, r1, lr}
	ldr.w r0, =0xE000ED88
	ldr   r1, [r0]
	orr   r1, r1, #(0xF << 20)
	str   r1, [r0]
	dsb
	isb
	pop   {r0, r1, pc}
