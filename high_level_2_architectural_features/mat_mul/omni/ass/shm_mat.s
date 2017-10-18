	.file	"shm_mat.c"
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
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$72, %rsp
	movl	%edi, -84(%rbp)
	movq	%rsi, -96(%rbp)
	movq	-96(%rbp), %rax
	addq	$8, %rax
	movq	(%rax), %rax
	movq	%rax, %rdi
	.cfi_offset 3, -40
	.cfi_offset 12, -32
	.cfi_offset 13, -24
	call	atoi
	movl	%eax, -60(%rbp)
	movl	-60(%rbp), %ebx
	movslq	%ebx, %rax
	subq	$1, %rax
	movq	%rax, -72(%rbp)
	movl	$17, -56(%rbp)
	movl	-60(%rbp), %eax
	movslq	%eax, %rdx
	movl	-60(%rbp), %eax
	cltq
	imulq	%rdx, %rax
	leaq	0(,%rax,4), %rcx
	movl	-56(%rbp), %eax
	movl	$950, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	shmget
	movl	%eax, -52(%rbp)
	cmpl	$-1, -52(%rbp)
	jne	.L2
	movl	$1, %edi
	call	exit
.L2:
	movl	-52(%rbp), %eax
	movl	$0, %edx
	movl	$0, %esi
	movl	%eax, %edi
	call	shmat
	movq	%rax, -48(%rbp)
	cmpq	$-1, -48(%rbp)
	jne	.L3
	movl	$1, %edi
	call	exit
.L3:
	movl	$0, -40(%rbp)
	jmp	.L4
.L7:
	movl	$0, -36(%rbp)
	jmp	.L5
.L6:
	movl	-40(%rbp), %eax
	movslq	%eax, %rdx
	movslq	%ebx, %rax
	imulq	%rdx, %rax
	salq	$2, %rax
	movq	%rax, %r12
	addq	-48(%rbp), %r12
	movl	-36(%rbp), %r13d
	call	rand
	movl	%eax, %edx
	sarl	$31, %edx
	shrl	$24, %edx
	addl	%edx, %eax
	andl	$255, %eax
	subl	%edx, %eax
	movl	%eax, %edx
	movslq	%r13d, %rax
	movl	%edx, (%r12,%rax,4)
	addl	$1, -36(%rbp)
.L5:
	movl	-36(%rbp), %eax
	cmpl	-60(%rbp), %eax
	jl	.L6
	addl	$1, -40(%rbp)
.L4:
	movl	-40(%rbp), %eax
	cmpl	-60(%rbp), %eax
	jl	.L7
	addq	$72, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.7 20120313 (Red Hat 4.4.7-18)"
	.section	.note.GNU-stack,"",@progbits
