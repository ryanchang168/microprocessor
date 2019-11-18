.syntax	unified
	.cpu	cortex-m4
	.thumb

.text
	.global	delay_1s
	.global	GPIO_init
	.global max7219_init
	.global max7219_send
	.equ	RCC_AHB2ENR,	0x4002104c
	.equ	timer,		0x100000	// 2^22 / 4 = 2^20

	.equ	GPIOA_MODER,	0x48000000
	.equ	GPIOA_OTYPER,	0x48000004
	.equ	GPIOA_OSPEEDR,	0x48000008
	.equ	GPIOA_PUPDR,	0x4800000c
	.equ	GPIOA_IDR,		0x48000010
	.equ	GPIOA_ODR,	0x48000014
	.equ	GPIOA_BSRR,		0x48000018 //set bit
	.equ	GPIOA_BRR,		0x48000028 //clear bit

	.equ	GPIOC_MODER,	0x48000800
	.equ	GPIOC_OTYPER,	0x48000804
	.equ	GPIOC_OSPEEDR,	0x48000808
	.equ	GPIOC_PUPDR,	0x4800080c
	.equ	GPIOC_ODR,	0x48000814

	//Din, CS, CLK offset
	.equ 	DIN,	0b100000 	//PA5
	.equ	CS,		0b1000000	//PA6
	.equ	CLK,	0b10000000	//PA7

	//max7219
	.equ	DECODE,			0x19 //decode control
	.equ	INTENSITY,		0x1A //brightness
	.equ	SCAN_LIMIT,		0x1B //how many digits to display
	.equ	SHUT_DOWN,		0x1C //shut down -- we did't use this actually
	.equ	DISPLAY_TEST,	0x1F //display test -- we did' use this actually


delay_1s:
	/* delay for one second */
	ldr	r0, =timer	// 2
	delay_L:
	subs	r0, r0, 1	// 1
	bne	delay_L		// 3 or 1
	bx	lr		// 1

GPIO_init:
//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
//RCC_AHB2ENR: enable GPIOA and B and C
    push {r0,r1,r2,lr}
    ldr r0, =RCC_AHB2ENR
    mov r1, 0b111
    str r1, [r0]

    //GPIOA_MODER: PA7 6 5: output
    ldr r0, =0b010101
    lsl r0, 10
    ldr r1, =GPIOA_MODER
    ldr r2, [r1]
    and r2, 0xFFFF03FF //clear 7 6 5
    orrs r2, r2, r0 //7 6 5  --> output
    str r2, [r1]

    ldr r0, =GPIOC_MODER
	ldr r1, [r0]
	//clear pc13 to zero
	and r1, r1, 0xf3ffffff
	str r1,	[r0]

    pop {r0,r1,r2,lr}
BX LR

max7219_init:
	//TODO: Initialize max7219 registers
	push {r0, r1, LR}
	ldr r0, =DECODE
	ldr r1, =0xFF //CODE B decode for digit 0-7
	bl max7219_send

	ldr r0, =DISPLAY_TEST
	ldr r1, =0x0 //normal operation
	bl max7219_send

	ldr r0, =INTENSITY
	ldr r1, =0xA //brightness (21/32)
	bl max7219_send

	ldr r0, =SCAN_LIMIT
	ldr r1, =0x7 //light up digit 0-7
	bl max7219_send

	ldr r0, =SHUT_DOWN
	ldr r1, =0x1 //normal operation
	bl max7219_send

	pop {r0, r1, PC}
	BX LR

max7219_send:
//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r0, r1, r2, r3, r4, r5, r6, r7, LR}
	lsl	r0, 8 //move to D15-D8
	add r0, r1 //r0 == din
	ldr r1, =DIN
	ldr r2, =CS
	ldr r3, =CLK
	ldr r4, =GPIOA_BSRR //-> 1
	ldr r5, =GPIOA_BRR //-> 0
	ldr r6, =0xF //now sending (r6)-th bit
	//b send_loop

send_loop:
    mov r7, 1
    lsl r7, r6
    str r3, [r5] //CLK -> 0
    tst r0, r7 //same as ANDS but discard the result (just update condition flags)
    beq bit_not_set //the sending bit(r0) != 1
    str r1, [r4] //din -> 1
    b if_done

bit_not_set: //send clear bit
    str r1, [r5] //din -> 0

if_done:
    str r3, [r4] //CLK -> 1
    subs r6, 0x1
    bge send_loop
    str r2, [r5] //CS -> 0
    str r2, [r4] //CS -> 1
    pop {r0, r1, r2, r3, r4, r5, r6, r7, PC}
    BX LR
