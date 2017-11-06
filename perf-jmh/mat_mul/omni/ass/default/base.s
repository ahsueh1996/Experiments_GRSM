	.file	"base.c"
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
	subq	$48, %rsp
	movl	%edi, -36(%rbp)
	movq	%rsi, -48(%rbp)
	movq	-48(%rbp), %rax
	addq	$8, %rax
	movq	(%rax), %rax
	movq	%rax, %rdi
	call	atoi
	movl	%eax, -20(%rbp)
	movl	$17, -16(%rbp)
	movl	-20(%rbp), %eax
	cltq
	subq	$1, %rax
	movq	%rax, -32(%rbp)
	movl	-20(%rbp), %eax
	movslq	%eax, %rdx
	movl	-20(%rbp), %eax
	cltq
	imulq	%rdx, %rax
	leaq	0(,%rax,4), %rcx
	movl	-16(%rbp), %eax
	movl	$438, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	shmget
	movl	%eax, -12(%rbp)
	cmpl	$-1, -12(%rbp)
	jne	.L2
	movl	$1, %edi
	call	exit
.L2:
	movl	-12(%rbp), %eax
	movl	$0, %edx
	movl	$0, %esi
	movl	%eax, %edi
	call	shmat
	movq	%rax, -8(%rbp)
	cmpq	$-1, -8(%rbp)
	jne	.L3
	movl	$1, %edi
	call	exit
.L3:
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.7 20120313 (Red Hat 4.4.7-18)"
	.section	.note.GNU-stack,"",@progbits
