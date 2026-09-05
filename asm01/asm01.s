section .data
    message db "1337",4

section .text
global _start

_start:
    mov rax,1
    mov rdi,1
    mov rsi,message
    mov rdx,4
    syscall

    mov rax,60
    xor rdi,rdi
    syscall