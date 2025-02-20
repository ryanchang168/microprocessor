.syntax unified
.cpu cortex-m4
.thumb

.data
	arr1: .byte 0x19, 0x89, 0x14, 0x32, 0x52, 0x23, 0x12, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC
.text
.global main
change_place:
	strb r3, [r6]
	strb r4, [r5]
	b loop2_cmp
do_sort:
	// r1, r2 are loop counters
	movs r1, 0
	loop1:
		movs r2, 0
		loop2:
			// r3 is the first value, and r4 is the second. r5, r6 are addresses of arr
			add r5, r0, r2
			ldrb r3, [r5]
			add r2, r2, 1
			add r6, r0, r2
			ldrb r4, [r6]
			// if r4 < r3 then change the place.
			cmp r3, r4
			blt change_place
			// if r2 < 7 then continue loop2
			loop2_cmp:
				cmp r2, 7
				bne loop2
		// if r1 < 7 then continue loop1
		add r1, r1, 1
		cmp r1, 7
		beq end_loop1
		b loop1
	end_loop1:
		bx lr
main:
	ldr r0, =arr1
	bl do_sort
	ldr r0, =arr2
	bl do_sort
L: b L
