section .data
    newline db 10

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
    jz prepare_output
    js exit_error
    add r13, rax
    jmp read_input

prepare_output:
    test r13, r13
    jz write_newline

    cmp byte [r12 + r13 - 1], 10
    jne reverse_string
    dec r13

    test r13, r13
    jz write_newline
    cmp byte [r12 + r13 - 1], 13
    jne reverse_string
    dec r13

reverse_string:
    xor r8, r8
    mov r9, r13
    dec r9

reverse_loop:
    cmp r8, r9
    jae write_string
    mov al, [r12 + r8]
    mov dl, [r12 + r9]
    mov [r12 + r8], dl
    mov [r12 + r9], al
    inc r8
    dec r9
    jmp reverse_loop

write_string:
    mov rax, 1
    mov rdi, 1
    mov rsi, r12
    mov rdx, r13
    syscall
    cmp rax, rdx
    jne exit_error

write_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    cmp rax, rdx
    jne exit_error
    xor rdi, rdi
    jmp exit

exit_error:
    mov rdi, 1

exit:
    mov rax, 60
    syscall
