	.cpu generic+fp+simd
	.file	"base.c"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB2:
	.cfi_startproc
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	add	x29, sp, 0
	.cfi_def_cfa_register 29
	stp	x19, x20, [sp,16]
	stp	x21, x22, [sp,32]
	.cfi_offset 19, -80
	.cfi_offset 20, -72
	.cfi_offset 21, -64
	.cfi_offset 22, -56
	str	w0, [x29,60]
	str	x1, [x29,48]
	ldr	x0, [x29,48]
	add	x0, x0, 8
	ldr	x0, [x0]
	bl	atoi
	str	w0, [x29,92]
	mov	w0, 17
	str	w0, [x29,88]
	ldr	w0, [x29,92]
	sxtw	x1, w0
	sub	x1, x1, #1
	str	x1, [x29,80]
	sxtw	x0, w0
	mov	x19, x0
	mov	x20, 0
	lsr	x0, x19, 59
	lsl	x22, x20, 5
	orr	x22, x0, x22
	lsl	x21, x19, 5
	ldr	w1, [x29,92]
	ldr	w0, [x29,92]
	sxtw	x1, w1
	sxtw	x0, w0
	mul	x0, x1, x0
	lsl	x1, x0, 2
	ldr	w0, [x29,88]
	mov	w2, 438
	bl	shmget
	str	w0, [x29,76]
	ldr	w0, [x29,76]
	cmn	w0, #1
	bne	.L2
	mov	w0, 1
	bl	exit
.L2:
	ldr	w0, [x29,76]
	mov	x1, 0
	mov	w2, 0
	bl	shmat
	str	x0, [x29,64]
	ldr	x0, [x29,64]
	cmn	x0, #1
	bne	.L3
	mov	w0, 1
	bl	exit
.L3:
	mov	w0, 0
	ldp	x19, x20, [sp,16]
	ldp	x21, x22, [sp,32]
	ldp	x29, x30, [sp], 96
	.cfi_restore 30
	.cfi_restore 29
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
