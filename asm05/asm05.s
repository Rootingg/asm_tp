section .text
global _start

_start:
    mov rsi, [rsp + 16]    
    mov rdx, 0            

count:
    cmp byte [rsi + rdx], 0
    je add_newline
    inc rdx
    jmp count

add_newline:
    mov byte [rsi + rdx], 10
    inc rdx

write:
    mov rax, 1
    mov rdi, 1
    syscall