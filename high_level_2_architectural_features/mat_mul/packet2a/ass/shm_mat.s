	.cpu generic+fp+simd
	.file	"shm_mat.c"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB2:
	.cfi_startproc
	stp	x29, x30, [sp, -128]!
	.cfi_def_cfa_offset 128
	.cfi_offset 29, -128
	.cfi_offset 30, -120
	add	x29, sp, 0
	.cfi_def_cfa_register 29
	stp	x19, x20, [sp,16]
	stp	x21, x22, [sp,32]
	str	x23, [sp,48]
	.cfi_offset 19, -112
	.cfi_offset 20, -104
	.cfi_offset 21, -96
	.cfi_offset 22, -88
	.cfi_offset 23, -80
	str	w0, [x29,76]
	str	x1, [x29,64]
	ldr	x0, [x29,64]
	add	x0, x0, 8
	ldr	x0, [x0]
	bl	atoi
	str	w0, [x29,116]
	ldr	w23, [x29,116]
	sxtw	x0, w23
	sub	x0, x0, #1
	str	x0, [x29,104]
	sxtw	x0, w23
	mov	x19, x0
	mov	x20, 0
	lsr	x0, x19, 59
	lsl	x22, x20, 5
	orr	x22, x0, x22
	lsl	x21, x19, 5
	mov	w0, 17
	str	w0, [x29,100]
	ldr	w1, [x29,116]
	ldr	w0, [x29,116]
	sxtw	x1, w1
	sxtw	x0, w0
	mul	x0, x1, x0
	lsl	x1, x0, 2
	ldr	w0, [x29,100]
	mov	w2, 950
	bl	shmget
	str	w0, [x29,96]
	ldr	w0, [x29,96]
	cmn	w0, #1
	bne	.L2
	mov	w0, 1
	bl	exit
.L2:
	ldr	w0, [x29,96]
	mov	x1, 0
	mov	w2, 0
	bl	shmat
	str	x0, [x29,88]
	ldr	x0, [x29,88]
	cmn	x0, #1
	bne	.L3
	mov	w0, 1
	bl	exit
.L3:
	str	wzr, [x29,124]
	b	.L4
.L7:
	str	wzr, [x29,120]
	b	.L5
.L6:
	ldrsw	x1, [x29,124]
	sxtw	x0, w23
	mul	x0, x1, x0
	lsl	x0, x0, 2
	ldr	x1, [x29,88]
	add	x19, x1, x0
	bl	rand
	mov	w1, w0
	asr	w0, w1, 31
	lsr	w0, w0, 24
	add	w1, w1, w0
	and	w1, w1, 255
	sub	w0, w1, w0
	mov	w1, w0
	ldrsw	x0, [x29,120]
	str	w1, [x19,x0,lsl 2]
	ldr	w0, [x29,120]
	add	w0, w0, 1
	str	w0, [x29,120]
.L5:
	ldr	w1, [x29,120]
	ldr	w0, [x29,116]
	cmp	w1, w0
	blt	.L6
	ldr	w0, [x29,124]
	add	w0, w0, 1
	str	w0, [x29,124]
.L4:
	ldr	w1, [x29,124]
	ldr	w0, [x29,116]
	cmp	w1, w0
	blt	.L7
	mov	w0, 0
	ldp	x19, x20, [sp,16]
	ldp	x21, x22, [sp,32]
	ldr	x23, [sp,48]
	ldp	x29, x30, [sp], 128
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 22
	.cfi_restore 21
	.cfi_restore 20
	.cfi_restore 19
	.cfi_def_cfa 31, 0
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	"GCC: (GNU) 4.8.5 20150623 (Red Hat 4.8.5-16)"
	.section	.note.GNU-stack,"",%progbits
