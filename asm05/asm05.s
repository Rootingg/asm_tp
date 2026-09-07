section .bss
    buf resb 16

section .text
global _start

_start: 
    mov rax,[rsp + 16]
    mov [buf],rax

    mov rax,1
    mov rdi,1
    mov rsi,[buf]
    mov rdx,5
    syscall

    mov rax,60
    mov rdi,0
    syscall