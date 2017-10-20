	.cpu generic+fp+simd
	.file	"elif.c"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB0:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	add	x29, sp, 0
	.cfi_def_cfa_register 29
	str	w0, [x29,28]
	str	x1, [x29,16]
	mov	x0, 0
	bl	time
	bl	srand
	ldr	x0, [x29,16]
	add	x0, x0, 8
	ldr	x0, [x0]
	bl	atoi
	str	w0, [x29,76]
	ldr	x0, [x29,16]
	add	x0, x0, 16
	ldr	x0, [x0]
	bl	atoi
	str	w0, [x29,72]
	bl	rand
	mov	w1, 1000
	sdiv	w2, w0, w1
	mov	w1, 1000
	mul	w1, w2, w1
	sub	w1, w0, w1
	ldr	w0, [x29,76]
	mul	w0, w1, w0
	str	w0, [x29,68]
	bl	rand
	mov	w1, 1000
	sdiv	w2, w0, w1
	mov	w1, 1000
	mul	w1, w2, w1
	sub	w1, w0, w1
	ldr	w0, [x29,76]
	mul	w0, w1, w0
	str	w0, [x29,64]
	ldr	w1, [x29,72]
	ldr	w0, [x29,76]
	mul	w0, w1, w0
	str	w0, [x29,60]
	ldr	w1, [x29,72]
	ldr	w0, [x29,76]
	mul	w0, w1, w0
	str	w0, [x29,56]
	ldr	w1, [x29,76]
	mov	w0, 707
	mul	w1, w1, w0
	ldr	w0, [x29,60]
	add	w0, w1, w0
	str	w0, [x29,52]
	ldr	w1, [x29,76]
	mov	w0, 707
	mul	w1, w1, w0
	ldr	w0, [x29,56]
	add	w0, w1, w0
	str	w0, [x29,48]
	str	wzr, [x29,44]
	ldr	w1, [x29,68]
	ldr	w0, [x29,60]
	cmp	w1, w0
	ble	.L2
	ldr	w0, [x29,44]
	add	w0, w0, 1
	str	w0, [x29,44]
	b	.L3
.L2:
	ldr	w1, [x29,64]
	ldr	w0, [x29,56]
	cmp	w1, w0
	bge	.L3
	ldr	w0, [x29,44]
	sub	w0, w0, #1
	str	w0, [x29,44]
.L3:
	mov	w0, 0
	ldp	x29, x30, [sp], 80
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa 31, 0
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 4.8.5 20150623 (Red Hat 4.8.5-16)"
	.section	.note.GNU-stack,"",%progbits
