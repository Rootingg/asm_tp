section .bss
    buffer resb 65536

section .text
global _start

_start:
    xor r12, r12
    xor r15, r15

read_input:
    mov rax, 0
    mov rdi, 0
    lea rsi, [buffer + r12]
    mov rdx, 65536
    sub rdx, r12
    jz prepare_output
    syscall
    test rax, rax
    jz prepare_output
    js exit_error
    add r12, rax
    jmp read_input

prepare_output:
    test r12, r12
    jz write_output

    cmp byte [buffer + r12 - 1], 10
    jne reverse_string
    dec r12
    mov r15, 1
    test r12, r12
    jz write_output
    cmp byte [buffer + r12 - 1], 13
    jne reverse_string
    dec r12

reverse_string:
    test r12, r12
    jz write_output
    xor r8, r8
    mov r9, r12
    dec r9

reverse_loop:
    cmp r8, r9
    jae write_output
    mov al, [buffer + r8]
    mov dl, [buffer + r9]
    mov [buffer + r8], dl
    mov [buffer + r9], al
    inc r8
    dec r9
    jmp reverse_loop

write_output:
    test r12, r12
    jz maybe_newline
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, r12
    syscall
    cmp rax, rdx
    jne exit_error

maybe_newline:
    test r15, r15
    jz success
    mov byte [buffer], 10
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, 1
    syscall
    cmp rax, rdx
    jne exit_error

success:
    xor rdi, rdi
    jmp exit

exit_error:
    mov rdi, 1

exit:
    mov rax, 60
    syscall
