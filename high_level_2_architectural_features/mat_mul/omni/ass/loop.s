	.file	"loop.c"
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
	leaq	0(,%rdx,4), %rsi
	movl	-52(%rbp), %edx
	movslq	%edx, %rcx
	subq	$1, %rcx
	movq	%rcx, -72(%rbp)
	movslq	%eax, %rcx
	movslq	%edx, %rax
	imulq	%rcx, %rax
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
	movl	$0, -28(%rbp)
	jmp	.L5
.L8:
	movl	$0, -20(%rbp)
	movl	$0, -24(%rbp)
	jmp	.L6
.L7:
	movl	-32(%rbp), %eax
	movslq	%eax, %rdx
	movslq	%ebx, %rax
	imulq	%rdx, %rax
	salq	$2, %rax
	addq	-40(%rbp), %rax
	movl	-24(%rbp), %edx
	movslq	%edx, %rdx
	movl	(%rax,%rdx,4), %ecx
	movl	-24(%rbp), %eax
	movslq	%eax, %rdx
	movslq	%ebx, %rax
	imulq	%rdx, %rax
	salq	$2, %rax
	addq	-40(%rbp), %rax
	movl	-28(%rbp), %edx
	movslq	%edx, %rdx
	movl	(%rax,%rdx,4), %eax
	imull	%ecx, %eax
	addl	%eax, -20(%rbp)
	addl	$1, -24(%rbp)
.L6:
	movl	-24(%rbp), %eax
	cmpl	-52(%rbp), %eax
	jl	.L7
	movq	%rsi, %rdi
	shrq	$2, %rdi
	movl	-32(%rbp), %edx
	movl	-28(%rbp), %ecx
	movq	-64(%rbp), %rax
	movslq	%ecx, %rcx
	movslq	%edx, %rdx
	imulq	%rdi, %rdx
	addq	%rdx, %rcx
	movl	-20(%rbp), %edx
	movl	%edx, (%rax,%rcx,4)
	addl	$1, -28(%rbp)
.L5:
	movl	-28(%rbp), %eax
	cmpl	-52(%rbp), %eax
	jl	.L8
	addl	$1, -32(%rbp)
.L4:
	movl	-32(%rbp), %eax
	cmpl	-52(%rbp), %eax
	jl	.L9
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
