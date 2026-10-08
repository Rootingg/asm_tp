section .text
global _start

_start:
    mov rax, 12
    xor rdi, rdi
    syscall
    test rax, rax
    js exit_error
    mov r12, rax
    xor r13, r13
    mov r14, 4096

grow_buffer:
    mov rdi, r12
    add rdi, r14
    mov rax, 12
    syscall
    cmp rax, rdi
    jb exit_error

read_input:
    cmp r13, r14
    jne do_read
    add r14, 4096
    jmp grow_buffer

do_read:
    mov rax, 0
    mov rdi, 0
    lea rsi, [r12 + r13]
    mov rdx, r14
    sub rdx, r13
    syscall
    test rax, rax
    jz prepare_check
    js exit_error
    add r13, rax
    jmp read_input

prepare_check:
    test r13, r13
    jz palindrome

    cmp byte [r12 + r13 - 1], 10
    jne check_palindrome
    dec r13

    test r13, r13
    jz palindrome
    cmp byte [r12 + r13 - 1], 13
    jne check_palindrome
    dec r13

check_palindrome:
    xor r8, r8
    mov r9, r13
    dec r9

compare_bytes:
    cmp r8, r9
    jae palindrome
    mov al, [r12 + r8]
    cmp al, [r12 + r9]
    jne not_palindrome
    inc r8
    dec r9
    jmp compare_bytes

palindrome:
    xor rdi, rdi
    jmp exit

not_palindrome:
    mov rdi, 1
    jmp exit

exit_error:
    mov rdi, 1

exit:
    mov rax, 60
    syscall
