section .data
    message db "1337", 13, 10, 0   

section .text
global _start

_start:
    cmp qword [rsp], 2
    jne fail

    mov rsi, [rsp + 16]

    cmp byte [rsi], '4'
    jne fail
    cmp byte [rsi + 1], '2'
    jne fail
    cmp byte [rsi + 2], 0
    jne fail

    mov rax, 1
    mov rdi, 1
    mov rsi, message
    mov rdx, 6
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

fail:
    mov rax, 60
    mov rdi, 1
    syscall