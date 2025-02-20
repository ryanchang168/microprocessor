	.syntax unified
	.cpu cortex-m4
	.thumb
.text
	.global max7219_init
	.global max7219_send
	.global GPIO_init
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_ODR, 0x48000014
	.equ MAX7219_DIN, 0b00100000
	.equ MAX7219_CS, 0b01000000
	.equ MAX7219_CLK, 0b10000000
	.equ BSRR, 0x48000018
	.equ BRR, 0x48000028

GPIO_init:
	push {r0, r1, r2, lr}
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	movs r0, 0b01
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
	pop {r0, r1, r2, lr}
	bx lr
/*
Display_Number:
	//TODO: Display 0 to F at first digit on 7-SEG LED. Display one	per second.
	push {lr}
	// r8 count from 0 to 7 because student number has 7
	movs r8, 0
	Display_Number_Loop:
		// r0 is digit0, r1 is data from arr
		ldr r1, =arr
		adds r1, r1, r8
		ldrb r1, [r1]
		adds r0, r8, 0b0001
		lsl r0, r0, 8

		movs r7, 0b1000000000000000
		adds r0, r0, r1
		bl Loop16
		adds r8, r8, 1
		// check whether 0xF
		cmp r8, 7
		blt Display_Number_Loop
	pop {lr}
	bx lr
*/
max7219_send:
	push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
	ldr r2, =MAX7219_DIN
	ldr r3, =MAX7219_CS
	ldr r4, =MAX7219_CLK
	ldr r5, =BSRR
	ldr r6, =BRR
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	lsl r0, r0, 0x8
	adds r0, r0, r1
	movs r7, 0b1000000000000000
	bl Loop16
	pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
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
	push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
	// Decode Mode
	movs r0, 0b1001
	movs r1, 0xff
	bl max7219_send
	// Intensity
	movs r0, 0b1010
	movs r1, 0b1111
	bl max7219_send
	// Scan Limit
	movs r0, 0b1011
	movs r1, 0b110
	bl max7219_send
	// Shutdown
	movs r0, 0b1100
	movs r1, 1
	bl max7219_send
	// Display Test
	movs r0, 0b1111
	movs r1, 0
	bl max7219_send

	pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
	bx lr
