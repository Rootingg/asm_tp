section .bss
    buffer resb 65536

section .text
global _start

_start:
    xor r12, r12

read_input:
    mov rax, 0
    mov rdi, 0
    lea rsi, [buffer + r12]
    mov rdx, 65536
    sub rdx, r12
    syscall
    test rax, rax
    jz prepare_check
    js exit_error
    add r12, rax
    cmp r12, 65536
    jb read_input

prepare_check:
    test r12, r12
    jz palindrome

    cmp byte [buffer + r12 - 1], 10
    jne check_palindrome
    dec r12

    test r12, r12
    jz palindrome
    cmp byte [buffer + r12 - 1], 13
    jne check_palindrome
    dec r12

check_palindrome:
    xor r8, r8
    mov r9, r12
    dec r9

compare_bytes:
    cmp r8, r9
    jae palindrome
    mov al, [buffer + r8]
    cmp al, [buffer + r9]
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
