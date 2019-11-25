	.syntax unified
	.cpu cortex-m4
	.thumb

.text
	.global gpio_init

	.equ RCC_AHB2ENR,  0x4002104C
	.equ RCC_APB2ENR,  0x40021060

	.equ DECODE_MODE,  0x09
	.equ DISPLAY_TEST, 0x0F
	.equ SCAN_LIMIT,   0x0B
	.equ INTENSITY,    0x0A
	.equ SHUTDOWN,     0x0C

	.equ MAX7219_DIN,  0x20 @ PA5
	.equ MAX7219_CS,   0x40 @ PA6
	.equ MAX7219_CLK,  0x80 @ PA7

	.equ GPIOA_BASE,   0x48000000
	.equ BSRR_OFFSET,  0x18 @ set bit
	.equ BRR_OFFSET,   0x28 @ clear bit

	.equ GPIOB_BASE,   0x48000400
	.equ AFRL_OFFSET,  0x20
	.equ AFRH_OFFSET,  0x24

	.equ GPIOC_BASE,   0x48000800

gpio_init:
	push {r0, r1, r2, lr}

	mov  r0, 0b00000000000000000000000000000111
	ldr  r1, =RCC_AHB2ENR
	str  r0, [r1]

	mov  r0, 0b00000000000000000000000000000001
	ldr  r1, =RCC_APB2ENR
	str  r0, [r1]

	ldr  r1, =GPIOA_BASE @ GPIOA_MODER
	ldr  r2, [r1]
	and  r2, 0b11111111111111111111001111111111
	orr  r2, 0b00000000000000000000010000000000
	str  r2, [r1]

	add  r1, 0x4 @ GPIOA_OTYPER
	ldr  r2, [r1]
	and  r2, 0b11111111111111111111111111011111
	str  r2, [r1]

	add  r1, 0x4 @ GPIOA_SPEEDER
	ldr  r2, [r1]
	and  r2, 0b11111111111111111111001111111111
	orr  r2, 0b00000000000000000000010000000000
	str  r2, [r1]

	add  r1, 0x4 @ GPIOA_PUPDR
	ldr  r2, [r1]
	and  r2, 0b11111111111111111111001111111111
	orr  r2, 0b00000000000000000000010000000000
	str  r2, [r1]

	add  r1, 0x8 @ GPIOA_ODR
	ldr  r2, [r1]
	orr  r2, 0b100000
	str  r2, [r1]

	pop  {r0, r1, r2, pc}

