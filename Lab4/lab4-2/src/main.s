.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr: .byte 0x0, 0x6, 0x1, 0x6, 0x0, 0x3, 0x2
.text
	.global main
	//GPIO
	.equ	RCC_AHB2ENR,	0x4002104C
	.equ	GPIOA_MODER,	0x48000000
	.equ	GPIOA_OTYPER,	0x48000004
	.equ	GPIOA_OSPEEDER,	0x48000008
	.equ	GPIOA_PUPDR,	0x4800000C
	.equ	GPIOA_IDR,		0x48000010
	.equ	GPIOA_ODR,		0x48000014  //PA5 6 7 output mode
	.equ	GPIOA_BSRR,		0x48000018 //set bit -> 1
	.equ	GPIOA_BRR,		0x48000028 //clear bit -> 0

	//Din, CS, CLK offset
	.equ 	DIN,	0b100000 	//PA5
	.equ	CS,		0b1000000	//PA6
	.equ	CLK,	0b10000000	//PA7

	//max7219
	.equ	DECODE,			0x19 //decode control
	.equ	INTENSITY,		0x1A //brightness
	.equ	SCAN_LIMIT,		0x1B //how many digits to display
	.equ	SHUT_DOWN,		0x1C //shut down -- we did't use this
	.equ	DISPLAY_TEST,	0x1F //display test -- we did' use this

main:
	BL GPIO_init
	BL max7219_init

Display0toF:
	ldr r8, =arr // arr裡面放的東西為依序的0到F
	mov r10, #7  // R10用來進算現在該顯示ARR裡面的第幾個
	mov r11, #0
	loop:
		mov r0, r10	// R0設為1表示 現在設定的是七段顯示器的第一個輸出
		ldrb r1, [r8,r11]	//R1則為R8(ARR的位址)+COUNTER(R10)的值
		bl MAX7219Send	//傳進去設定
		add r11, r11, #1
		subs r10, r10, #1 //R10+1 讓下次顯示的數字為ARR裡面的下一個
		beq Display0toF
		b loop
GPIO_init:
	//enable GPIO port A
	ldr r0, =RCC_AHB2ENR
	mov r1, 0b1
	str r1, [r0]

	//enable GPIO PA7,6,5 for output mode=01
	ldr r0, =GPIOA_MODER
	ldr r1, =0xABFF57FF//0xFFFF 01 01 01 (765) 11 FF
	str r1, [r0]

	//GPIOA_OTYPER: push-pull (reset state)

	//default low speed, set to high speed=10
	ldr r0, =GPIOA_OSPEEDER
	ldr r1, =0x0000A800 //1010 10(765)00 00
	str r1, [r0]

	BX LR


MAX7219Send:
	lsl r0, r0, #8 //把R0變成高8位
	add r0, r0, r1 //R0+R1變成DIN應該要有的值，存在R0
	ldr r1, =DIN
	ldr r2, =CS
	ldr r3, =CLK
	ldr r4, =GPIOA_BSRR //-> 1
	ldr r5, =GPIOA_BRR //-> 0
	ldr r6, =0xF

send_loop:
	mov r7, #1
	lsl r7, r7, r6	// 用來測試 R0 的BYTE 從第16檢視到第一個
	str r3, [r5]  // 先把CLK設定成0
	tst r0, r7	  // 看看R0的第R7個BYTE是否為一
	beq bit_not_set //如果是一，則不進去
	str r1, [r4]	//把DIN設定成1
	b if_done

bit_not_set:
	str r1, [r5] //因為R0就是DIN的值，因此R0的BYTE如果不為1，則為0，把DIN設定成0

if_done:
	str r3, [r4] 	//CLK設定成1
	sub r6, r6, #1  //檢視R0的前一個位數
	cmp r6, 0		//是0的話就代表DIN的值都設定完了
	bge send_loop	//還沒設定玩就跳回去繼續設定
	str r2, [r5]	//若都設定玩則把CS設定成0
	str r2, [r4]	//再把CS設定成1
	bx lr



max7219_init:
	//TODO: Initialize max7219 registers
	push {r0, r1, LR}
	ldr r0, =DECODE
	ldr r1, =0xFF //NO DECODE
	bl MAX7219Send

	ldr r0, =DISPLAY_TEST
	ldr r1, =0x0 //normal operation
	bl MAX7219Send

	ldr r0, =INTENSITY
	ldr r1, =0xA // 21/32 (brightness)
	bl MAX7219Send

	ldr r0, =SCAN_LIMIT
	ldr r1, =0x6 //only light up digit 0
	bl MAX7219Send

	ldr r0, =SHUT_DOWN
	ldr r1, =0x1 //normal operation
	bl MAX7219Send

	pop {r0, r1, PC}
	BX LR

