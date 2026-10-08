section .bss
    buffer resb 65536

section .data
    newline db 10

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
    jz prepare_output
    js exit_error
    add r12, rax
    cmp r12, 65536
    jb read_input

prepare_output:
    test r12, r12
    jz write_newline

    cmp byte [buffer + r12 - 1], 10
    jne reverse_string
    dec r12

    test r12, r12
    jz write_newline
    cmp byte [buffer + r12 - 1], 13
    jne reverse_string
    dec r12

reverse_string:
    xor r8, r8
    mov r9, r12
    dec r9

reverse_loop:
    cmp r8, r9
    jae write_string
    mov al, [buffer + r8]
    mov dl, [buffer + r9]
    mov [buffer + r8], dl
    mov [buffer + r9], al
    inc r8
    dec r9
    jmp reverse_loop

write_string:
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, r12
    syscall

write_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    xor rdi, rdi
    jmp exit

exit_error:
    mov rdi, 1

exit:
    mov rax, 60
    syscall
