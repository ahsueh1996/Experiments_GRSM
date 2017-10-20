	.file	"elif_r.c"
	.text
.globl main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$72, %rsp
	movl	%edi, -68(%rbp)
	movq	%rsi, -80(%rbp)
	movl	$0, %edi
	.cfi_offset 3, -24
	call	time
	movq	%rax, %rdi
	movl	$0, %eax
	call	srand
	movq	-80(%rbp), %rax
	addq	$8, %rax
	movq	(%rax), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	atoi
	movl	%eax, -56(%rbp)
	movq	-80(%rbp), %rax
	addq	$16, %rax
	movq	(%rax), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	atoi
	movl	%eax, -52(%rbp)
	movl	$0, %eax
	call	rand
	movl	%eax, %ecx
	movl	$274877907, %edx
	movl	%ecx, %eax
	imull	%edx
	sarl	$6, %edx
	movl	%ecx, %eax
	sarl	$31, %eax
	movl	%edx, %ebx
	subl	%eax, %ebx
	movl	%ebx, %eax
	movl	%eax, -48(%rbp)
	movl	-48(%rbp), %eax
	imull	$1000, %eax, %eax
	movl	%ecx, %edx
	subl	%eax, %edx
	movl	%edx, %eax
	movl	%eax, -48(%rbp)
	movl	$0, %eax
	call	rand
	movl	%eax, %ecx
	movl	$274877907, %edx
	movl	%ecx, %eax
	imull	%edx
	sarl	$6, %edx
	movl	%ecx, %eax
	sarl	$31, %eax
	movl	%edx, %ebx
	subl	%eax, %ebx
	movl	%ebx, %eax
	movl	%eax, -44(%rbp)
	movl	-44(%rbp), %eax
	imull	$1000, %eax, %eax
	movl	%ecx, %edx
	subl	%eax, %edx
	movl	%edx, %eax
	movl	%eax, -44(%rbp)
	movl	-52(%rbp), %eax
	movl	%eax, -40(%rbp)
	movl	-52(%rbp), %eax
	movl	%eax, -36(%rbp)
	movl	-40(%rbp), %eax
	addl	$707, %eax
	movl	%eax, -32(%rbp)
	movl	-36(%rbp), %eax
	addl	$707, %eax
	movl	%eax, -28(%rbp)
	movl	$0, -24(%rbp)
	movl	$0, -20(%rbp)
	jmp	.L2
.L5:
	movl	-48(%rbp), %eax
	cmpl	-40(%rbp), %eax
	jle	.L3
	addl	$1, -24(%rbp)
	jmp	.L4
.L3:
	movl	-44(%rbp), %eax
	cmpl	-36(%rbp), %eax
	jge	.L4
	subl	$1, -24(%rbp)
.L4:
	addl	$1, -20(%rbp)
.L2:
	movl	-20(%rbp), %eax
	cmpl	-56(%rbp), %eax
	jl	.L5
	movl	$0, %eax
	addq	$72, %rsp
	popq	%rbx
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.7 20120313 (Red Hat 4.4.7-18)"
	.section	.note.GNU-stack,"",@progbits
