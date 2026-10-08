section .bss
	buffer resb 32

section .text
global _start

_start:
	cmp qword [rsp], 2
	je decimal_arguments
	cmp qword [rsp], 3
	je binary_arguments
	jmp usage_error

decimal_arguments:
	mov rsi, [rsp + 16]
	cmp byte [rsi], '-'
	jne decimal_mode
	cmp byte [rsi + 1], 'b'
	jne decimal_mode
	cmp byte [rsi + 2], 0
	je usage_error

decimal_mode:
	mov r12, 16
	jmp parse_number

binary_arguments:
	mov rsi, [rsp + 16]
	cmp byte [rsi], '-'
	jne usage_error
	cmp byte [rsi + 1], 'b'
	jne usage_error
	cmp byte [rsi + 2], 0
	jne usage_error
	mov rsi, [rsp + 24]
	mov r12, 2
	jmp parse_number

parse_number:
	xor rax, rax
	xor r13, r13
	xor r8, r8

	cmp byte [rsi], '-'
	jne parse_digit
	mov r13, 1
	inc rsi

parse_digit:
	movzx rdx, byte [rsi]
	cmp dl, 0
	je parsed_number
	cmp dl, '0'
	jb invalid_number
	cmp dl, '9'
	ja invalid_number
	sub dl, '0'
	mov r9, 922337203685477580
	cmp rax, r9
	ja invalid_number
	jne add_digit
	test r13, r13
	jnz negative_limit
	cmp dl, 7
	ja invalid_number
	jmp add_digit

negative_limit:
	cmp dl, 8
	ja invalid_number

add_digit:
	imul rax, rax, 10
	add rax, rdx
	inc r8
	inc rsi
	jmp parse_digit

parsed_number:
	test r8, r8
	jz invalid_number

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

	test r13, r13
	jz write_result
	dec rdi
	mov byte [rdi], '-'
	inc r8

write_result:
	mov rax, 1
	mov rsi, rdi
	mov rdi, 1
	lea rdx, [buffer + 32]
	sub rdx, rsi
	syscall
	jmp exit

invalid_number:
	mov rax, 60
	mov rdi, 1
	syscall

usage_error:
	mov rax, 60
	mov rdi, 2
	syscall

exit:
	mov rax, 60
	xor rdi, rdi
	syscall
