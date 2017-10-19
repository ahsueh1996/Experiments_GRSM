	.file	"loop_ikj.c"
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
	pushq	%r12
	pushq	%rbx
	subq	$96, %rsp
	movl	%edi, -100(%rbp)
	movq	%rsi, -112(%rbp)
	movq	%rsp, %rax
	movq	%rax, %r12
	.cfi_offset 3, -32
	.cfi_offset 12, -24
	movq	-112(%rbp), %rax
	addq	$8, %rax
	movq	(%rax), %rax
	movq	%rax, %rdi
	call	atoi
	movl	%eax, -52(%rbp)
	movl	$17, -48(%rbp)
	movl	-52(%rbp), %ebx
	movslq	%ebx, %rax
	subq	$1, %rax
	movq	%rax, -88(%rbp)
	movl	-52(%rbp), %eax
	movslq	%eax, %rdx
	movl	-52(%rbp), %eax
	cltq
	imulq	%rdx, %rax
	leaq	0(,%rax,4), %rcx
	movl	-48(%rbp), %eax
	movl	$438, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	shmget
	movl	%eax, -44(%rbp)
	cmpl	$-1, -44(%rbp)
	jne	.L2
	movl	$1, %edi
	call	exit
.L2:
	movl	-44(%rbp), %eax
	movl	$0, %edx
	movl	$0, %esi
	movl	%eax, %edi
	call	shmat
	movq	%rax, -40(%rbp)
	cmpq	$-1, -40(%rbp)
	jne	.L3
	movl	$1, %edi
	call	exit
.L3:
	movl	-52(%rbp), %eax
	movslq	%eax, %rdx
	subq	$1, %rdx
	movq	%rdx, -80(%rbp)
	movslq	%eax, %rdx
	leaq	0(,%rdx,4), %rcx
	movl	-52(%rbp), %edx
	movslq	%edx, %rsi
	subq	$1, %rsi
	movq	%rsi, -72(%rbp)
	movslq	%eax, %rsi
	movslq	%edx, %rax
	imulq	%rsi, %rax
	salq	$2, %rax
	addq	$15, %rax
	addq	$15, %rax
	shrq	$4, %rax
	salq	$4, %rax
	subq	%rax, %rsp
	movq	%rsp, %rax
	addq	$15, %rax
	shrq	$4, %rax
	salq	$4, %rax
	movq	%rax, -64(%rbp)
	movl	$0, -32(%rbp)
	jmp	.L4
.L9:
	movl	$0, -24(%rbp)
	jmp	.L5
.L8:
	movl	-32(%rbp), %eax
	movslq	%eax, %rdx
	movslq	%ebx, %rax
	imulq	%rdx, %rax
	salq	$2, %rax
	addq	-40(%rbp), %rax
	movl	-24(%rbp), %edx
	movslq	%edx, %rdx
	movl	(%rax,%rdx,4), %eax
	movl	%eax, -20(%rbp)
	movl	$0, -28(%rbp)
	jmp	.L6
.L7:
	movq	%rcx, %r9
	shrq	$2, %r9
	movl	-32(%rbp), %r8d
	movl	-28(%rbp), %edi
	movq	%rcx, %r10
	shrq	$2, %r10
	movl	-32(%rbp), %edx
	movl	-28(%rbp), %esi
	movq	-64(%rbp), %rax
	movslq	%esi, %rsi
	movslq	%edx, %rdx
	imulq	%r10, %rdx
	leaq	(%rsi,%rdx), %rdx
	movl	(%rax,%rdx,4), %esi
	movl	-24(%rbp), %eax
	movslq	%eax, %rdx
	movslq	%ebx, %rax
	imulq	%rdx, %rax
	salq	$2, %rax
	addq	-40(%rbp), %rax
	movl	-28(%rbp), %edx
	movslq	%edx, %rdx
	movl	(%rax,%rdx,4), %eax
	imull	-20(%rbp), %eax
	addl	%eax, %esi
	movq	-64(%rbp), %rax
	movslq	%edi, %rdi
	movslq	%r8d, %rdx
	imulq	%r9, %rdx
	leaq	(%rdi,%rdx), %rdx
	movl	%esi, (%rax,%rdx,4)
	addl	$1, -28(%rbp)
.L6:
	movl	-28(%rbp), %eax
	cmpl	-52(%rbp), %eax
	jl	.L7
	addl	$1, -24(%rbp)
.L5:
	movl	-24(%rbp), %eax
	cmpl	-52(%rbp), %eax
	jl	.L8
	addl	$1, -32(%rbp)
.L4:
	movl	-32(%rbp), %eax
	cmpl	-52(%rbp), %eax
	jl	.L9
	movl	$0, %eax
	movq	%r12, %rsp
	leaq	-16(%rbp), %rsp
	addq	$0, %rsp
	popq	%rbx
	popq	%r12
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.7 20120313 (Red Hat 4.4.7-18)"
	.section	.note.GNU-stack,"",@progbits
