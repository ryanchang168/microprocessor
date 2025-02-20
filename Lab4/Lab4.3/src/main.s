	.syntax unified
	.cpu cortex-m4
	.thumb
.data

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_ODR, 0x48000014
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_IDR, 0x48000810
	.equ MAX7219_DIN, 0b00100000
	.equ MAX7219_CS, 0b01000000
	.equ MAX7219_CLK, 0b10000000
	.equ BSRR, 0x48000018
	.equ BRR, 0x48000028
main:
	bl GPIO_init
	// let r2~r6 to the correspond address
 	ldr r2, =MAX7219_DIN
	ldr r3, =MAX7219_CS
	ldr r4, =MAX7219_CLK
	ldr r5, =BSRR
	ldr r6, =BRR
	bl max7219_init
loop:
	bl Show_Digits
	bl Negative1
	b loop
GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	movs r0, 0b101
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]

	ldr r1, =GPIOA_MODER
	ldr r0, [r1]
	and r0, 0b11111111111111110000001111111111
	orr r0, 0b00000000000000000101010000000000
	str r0, [r1]

	movs r0, 0b1010100000000000
	ldr r1, =GPIOA_OSPEEDR
	str r0, [r1]

	movs r0, 0
	ldr r1, =GPIOA_ODR
	str r0, [r1]

	ldr r0, =#0xf3ffffff
	ldr r1, =GPIOC_MODER
	str r0, [r1]

	movs r0, 0b10000000000000
	ldr r1, =GPIOC_IDR
	str r0, [r1]

	bx lr
Show_Digits:
	push {lr}
	// r8, r9 for fibonacii initial values
	movs r8, 0
	movs r9, 1
	// at first var=0
	movs r7, 0b1000000000000000
	movs r0, 0b000100000000
	bl Loop16
	bl Wait_Pressed
	// r11 to log the value of what digit, so initial r9
	movs r11, r9
	// r13 for counter
	movs r12, 0b0001
	Show_Digit_Loop:
		movs r1, 10
		sdiv r10, r11, r1
		mul r10, r10, r1
		subs r10, r11, r10
		Check_Digit:
			movs r0, r12
			lsl r0, 8
			movs r7, 0b1000000000000000
			adds r0, r0, r10
			bl Loop16
			movs r1, 10
			sdiv r11, r11, r1
			adds r12, r12, 1
			cmp r11, 0
			bne Show_Digit_Loop
	// get the next fibonacii value
	movs r10, r9
	adds r9, r9, r8
	movs r8, r10
	// check whether greater than 10000000
	ldr r10, =10000000
	cmp r9, r10
	blt Wait_Pressed
	pop {lr}
	bx lr
Negative1:
	push {lr}
	// display -1
	ldr r0, =0b000100000001
	movs r7, 0b1000000000000000
	bl Loop16
	ldr r0, =0b001000001010
	movs r7, 0b1000000000000000
	bl Loop16

	bl Wait_Pressed
	pop {lr}
	bx lr
MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {lr}
	adds r0, r0, r1
	movs r7, 0b1000000000000000
	bl Loop16
	pop {lr}
	bx lr
Loop16:
	// set the clock to 0
	str r4, [r6]
	// check r7 bit is 0 or 1 and then set DIN
	tst r0, r7
	beq Clear
	str r2, [r5]
	b Done
	Clear:
		str r2, [r6]
	Done:
		// set the clock to 1
		lsr r7, r7, 1
		str r4, [r5]
		// check if all 16 bits are in and set CS from 0 to 1
		cmp r7, 0
		bne Loop16
		str r3, [r6]
		str r3, [r5]
	bx lr
max7219_init:
	//TODO: Initialize max7219 registers
	push {lr}
	// Decode Mode
	movs r0, 0b100100000000
	movs r1, 0xff
	bl MAX7219Send
	// Intensity
	movs r0, 0b101000000000
	movs r1, 0b1111
	bl MAX7219Send
	// Scan Limit
	movs r0, 0b101100000000
	movs r1, 0b111
	bl MAX7219Send
	// Shutdown
	movs r0, 0b110000000000
	movs r1, 1
	bl MAX7219Send
	// Display Test
	movs r0, 0b111100000000
	movs r1, 0
	bl MAX7219Send

	pop {lr}
	bx lr
Wait_Pressed:
	// Keep looking IDR. r7 for how many 0 in raw.
	ldr r0, =GPIOC_IDR
	movs r7, 0
	Monitoring:
		ldr r1, [r0]
		ands r1, 0b1000000000000
		cmp r1, 0b1000000000000
		beq Reset
		adds r7, r7, 1
		b Monitoring
		Reset:
			ldr r8, =1000000
			cmp r7, r8
			bge loop
			cmp r7, 1000
			bge After_Pressed
			movs r7, 0
			b Monitoring
	After_Pressed:
		bx lr

