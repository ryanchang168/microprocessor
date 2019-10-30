	.syntax unified
	.cpu cortex-m4
	.thumb
.data
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
	.equ 	GPIOC_MODER, 	0x48000800
	.equ 	GPIOC_IDR, 		0x48000810
	.equ 	Y,              1000

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

from_zero:
	ldr r8, =0
	ldr r9, =1
	bl print
loop:
	ldr r5,	=GPIOC_IDR
    ldr r6,	[r5]
    movs r7, #1
    lsl r7,	#13
    ands r6, r7
    it eq
    bleq pressed
    ldr r10, =0x2FFFF
    cmp r3, r10
    ldr r3, =0
    bgt from_zero
	b loop
GPIO_init:
	//enable GPIO port A
	ldr r0, =RCC_AHB2ENR
	mov r1, 0b101
	str r1, [r0]

	//enable GPIO PA7,6,5 for output mode=01
	ldr r0, =GPIOA_MODER
	ldr r1, =0xABFF57FF//0xFFFF 01 01 01 (765) 11 FF
	str r1, [r0]

	//GPIOA_OTYPER: push-pull (reset state)

	ldr r0, =GPIOC_MODER
	ldr r1, [r0]
	//clear pc13 to zero
	and r1, r1, 0xf3ffffff
	str r1,	[r0]

	//default low speed, set to high speed=10
	ldr r0, =GPIOA_OSPEEDER
	ldr r1, =0x0000A800 //1010 10(765)00 00
	str r1, [r0]

	BX LR


MAX7219Send:
	push {r0, r1, r2, r3, r4, r5, r6, r7, LR}
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
	pop {r0, r1, r2, r3, r4, r5, r6, r7, pc}

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
	ldr r1, =0x7 //only light up digit 0
	bl MAX7219Send

	ldr r0, =SHUT_DOWN
	ldr r1, =0x1 //normal operation
	bl MAX7219Send

	pop {r0, r1, PC}

pressed:
	push {lr}
	add r10, r8, r9
	mov r8, r9
	mov r9, r10
	lsr r10, r8, #26
	cmp r10, #0
	bgt overflow
	bl print
L1:	ldr r4,	=Y
	add r3, r3, #1
L2: ldr r5,	=GPIOC_IDR
    ldr r6,	[r5]
    movs r7, #1
    lsl r7,	#13
    ands r6, r7
    beq L1
	subs R4, #1
	bne L2
	pop {pc}
print:
	push {r2,r3,r4,lr}
	ldr r0, =0x01
	ldr r10, =10
	mov r2, r8
bcdloop:
	cmp r10, #1
	it eq
	ldreq r1, =0x0f
	beq L3
	sdiv r3, r2, r10
	mul r4, r3, r10
	sub r1, r2, r4
	mov r2, r3
	cmp r3, #0
	it eq
	moveq r10, #1
L3:	BL MAX7219Send
	add r0, r0, #1
	cmp r0, #9
	blt bcdloop
	pop {r2,r3,r4,pc}
overflow:
	push {r2,r3,r4,lr}
	ldr r0, =0x01
L4:	cmp r0, #2
	it lt
	ldrlt r1, =0x01
	it eq
	ldreq r1, =0x0a
	it gt
	ldrgt r1, =0x0f
	BL MAX7219Send
	add r0, r0, #1
	cmp r0, #9
	blt L4
	pop {r2,r3,r4,lr}
	b L1

