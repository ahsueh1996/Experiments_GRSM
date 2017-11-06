	.cpu generic+fp+simd
	.file	"loop_ikj.c"
	.global	__multi3
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB2:
	.cfi_startproc
	stp	x29, x30, [sp, -288]!
	.cfi_def_cfa_offset 288
	.cfi_offset 29, -288
	.cfi_offset 30, -280
	add	x29, sp, 0
	.cfi_def_cfa_register 29
	stp	x19, x20, [sp,16]
	stp	x21, x22, [sp,32]
	stp	x23, x24, [sp,48]
	stp	x25, x26, [sp,64]
	stp	x27, x28, [sp,80]
	stp	d8, d9, [sp,96]
	.cfi_offset 19, -272
	.cfi_offset 20, -264
	.cfi_offset 21, -256
	.cfi_offset 22, -248
	.cfi_offset 23, -240
	.cfi_offset 24, -232
	.cfi_offset 25, -224
	.cfi_offset 26, -216
	.cfi_offset 27, -208
	.cfi_offset 28, -200
	.cfi_offset 72, -192
	.cfi_offset 73, -184
	str	w0, [x29,204]
	str	x1, [x29,192]
	mov	x0, sp
	fmov	d9, x0
	ldr	x0, [x29,192]
	add	x0, x0, 8
	ldr	x0, [x0]
	bl	atoi
	str	w0, [x29,272]
	mov	w0, 17
	str	w0, [x29,268]
	ldr	s8, [x29,272]
	fmov	w1, s8
	sxtw	x0, w1
	sub	x0, x0, #1
	str	x0, [x29,256]
	fmov	w2, s8
	sxtw	x0, w2
	mov	x21, x0
	mov	x22, 0
	lsr	x0, x21, 59
	lsl	x4, x22, 5
	str	x4, [x29,184]
	ldr	x1, [x29,184]
	orr	x0, x0, x1
	str	x0, [x29,184]
	lsl	x2, x21, 5
	ldr	w1, [x29,272]
	ldr	w0, [x29,272]
	sxtw	x1, w1
	sxtw	x0, w0
	mul	x0, x1, x0
	lsl	x1, x0, 2
	ldr	w0, [x29,268]
	mov	w2, 438
	bl	shmget
	str	w0, [x29,252]
	ldr	w0, [x29,252]
	cmn	w0, #1
	bne	.L2
	mov	w0, 1
	bl	exit
.L2:
	ldr	w0, [x29,252]
	mov	x1, 0
	mov	w2, 0
	bl	shmat
	str	x0, [x29,240]
	ldr	x0, [x29,240]
	cmn	x0, #1
	bne	.L3
	mov	w0, 1
	bl	exit
.L3:
	ldr	w21, [x29,272]
	ldr	w22, [x29,272]
	sxtw	x0, w21
	sub	x0, x0, #1
	str	x0, [x29,232]
	sxtw	x0, w21
	mov	x19, x0
	mov	x20, 0
	lsr	x0, x19, 59
	lsl	x28, x20, 5
	orr	x28, x0, x28
	lsl	x27, x19, 5
	sxtw	x0, w21
	lsl	x19, x0, 2
	sxtw	x0, w22
	sub	x0, x0, #1
	str	x0, [x29,224]
	sxtw	x0, w21
	str	x0, [x29,160]
	str	xzr, [x29,168]
	sxtw	x0, w22
	str	x0, [x29,144]
	str	xzr, [x29,152]
	ldp	x0, x1, [x29,160]
	ldp	x2, x3, [x29,144]
	bl	__multi3
	lsr	x2, x0, 59
	lsl	x26, x1, 5
	orr	x26, x2, x26
	lsl	x25, x0, 5
	sxtw	x0, w21
	str	x0, [x29,128]
	str	xzr, [x29,136]
	sxtw	x0, w22
	str	x0, [x29,112]
	str	xzr, [x29,120]
	ldp	x0, x1, [x29,128]
	ldp	x2, x3, [x29,112]
	bl	__multi3
	lsr	x2, x0, 59
	lsl	x24, x1, 5
	orr	x24, x2, x24
	lsl	x23, x0, 5
	sxtw	x1, w21
	sxtw	x0, w22
	mul	x0, x1, x0
	lsl	x0, x0, 2
	add	x0, x0, 3
	add	x0, x0, 15
	lsr	x0, x0, 4
	lsl	x0, x0, 4
	mov	x4, sp
	sub	sp, x4, x0
	mov	x0, sp
	add	x0, x0, 3
	lsr	x0, x0, 2
	lsl	x0, x0, 2
	str	x0, [x29,216]
	str	wzr, [x29,284]
	b	.L4
.L9:
	str	wzr, [x29,276]
	b	.L5
.L8:
	ldrsw	x1, [x29,284]
	fmov	w2, s8
	sxtw	x0, w2
	mul	x0, x1, x0
	lsl	x0, x0, 2
	ldr	x1, [x29,240]
	add	x0, x1, x0
	ldrsw	x1, [x29,276]
	ldr	w0, [x0,x1,lsl 2]
	str	w0, [x29,212]
	str	wzr, [x29,280]
	b	.L6
.L7:
	lsr	x1, x19, 2
	lsr	x2, x19, 2
	ldr	x0, [x29,216]
	ldrsw	x3, [x29,280]
	ldrsw	x4, [x29,284]
	mul	x2, x4, x2
	add	x2, x3, x2
	ldr	w2, [x0,x2,lsl 2]
	ldrsw	x3, [x29,276]
	fmov	w4, s8
	sxtw	x0, w4
	mul	x0, x3, x0
	lsl	x0, x0, 2
	ldr	x3, [x29,240]
	add	x0, x3, x0
	ldrsw	x3, [x29,280]
	ldr	w3, [x0,x3,lsl 2]
	ldr	w0, [x29,212]
	mul	w0, w3, w0
	add	w2, w2, w0
	ldr	x0, [x29,216]
	ldrsw	x3, [x29,280]
	ldrsw	x4, [x29,284]
	mul	x1, x4, x1
	add	x1, x3, x1
	str	w2, [x0,x1,lsl 2]
	ldr	w0, [x29,280]
	add	w0, w0, 1
	str	w0, [x29,280]
.L6:
	ldr	w1, [x29,280]
	ldr	w0, [x29,272]
	cmp	w1, w0
	blt	.L7
	ldr	w0, [x29,276]
	add	w0, w0, 1
	str	w0, [x29,276]
.L5:
	ldr	w1, [x29,276]
	ldr	w0, [x29,272]
	cmp	w1, w0
	blt	.L8
	ldr	w0, [x29,284]
	add	w0, w0, 1
	str	w0, [x29,284]
.L4:
	ldr	w1, [x29,284]
	ldr	w0, [x29,272]
	cmp	w1, w0
	blt	.L9
	mov	w0, 0
	fmov	x1, d9
	mov	sp, x1
	add	sp, x29, 0
	.cfi_def_cfa_register 31
	ldp	x19, x20, [sp,16]
	ldp	x21, x22, [sp,32]
	ldp	x23, x24, [sp,48]
	ldp	x25, x26, [sp,64]
	ldp	x27, x28, [sp,80]
	ldp	d8, d9, [sp,96]
	ldp	x29, x30, [sp], 288
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 73
	.cfi_restore 72
	.cfi_restore 28
	.cfi_restore 27
	.cfi_restore 26
	.cfi_restore 25
	.cfi_restore 24
	.cfi_restore 23
	.cfi_restore 22
	.cfi_restore 21
	.cfi_restore 20
	.cfi_restore 19
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	"GCC: (GNU) 4.8.5 20150623 (Red Hat 4.8.5-16)"
	.section	.note.GNU-stack,"",%progbits
