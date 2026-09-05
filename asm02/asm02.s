section .data
    message db "1337",4
    input db 0

section .text
global _start

_start:

    mov rax,0
    mov rdi,0
    mov rsi,input
    mov rdx,4
    syscall

    cmp word [input], "42"
    jne exit

    mov rax,1
    mov rdi,1
    mov rsi,message
    mov rdx,4
    syscall

    mov rax,60
    xor rdi,rdi
    syscall

exit:
    mov rax,60
    xor rdi,rdi
    syscall