section .bss
	buffer resb 32

section .text
global _start

_start:
	mov rsi, [rsp + 16]
	cmp byte [rsi], '-'
	jne parse_number

	cmp byte [rsi + 1], 'b'
	jne exit
	cmp byte [rsi + 2], 0
	jne exit
	mov r12, 2
	mov rsi, [rsp + 24]
	jmp parse_number

parse_number:
	xor rax, rax
	xor rcx, rcx

parse_digit:
	movzx rdx, byte [rsi]
	cmp dl, 0
	je convert
	cmp dl, '0'
	jb exit
	cmp dl, '9'
	ja exit
	imul rax, rax, 10
	sub dl, '0'
	add rax, rdx
	inc rsi
	jmp parse_digit

convert:
	test r12, r12
	jnz convert_number
	mov r12, 16

convert_number:
	mov rdi, buffer
	add rdi, 32
	mov byte [rdi - 1], 10
	dec rdi
	xor r8, r8

convert_digit:
	xor rdx, rdx
	div r12
	cmp dl, 9
	jbe digit_is_numeric
	add dl, 'A' - 10
	jmp store_digit

digit_is_numeric:
	add dl, '0'

store_digit:
	dec rdi
	mov [rdi], dl
	inc r8
	test rax, rax
	jnz convert_digit

	mov rax, 1
	mov rsi, rdi
	mov rdi, 1
	lea rdx, [buffer + 32]
	sub rdx, rsi
	syscall

exit:
	mov rax, 60
	xor rdi, rdi
	syscall
