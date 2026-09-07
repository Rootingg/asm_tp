section .text
global _start

_start:
    mov rsi, [rsp + 16]    
    mov rdx, 0            

count:
    cmp byte [rsi + rdx], 0 
    je write
    inc rdx
    jmp count

write:
    mov rax, 1             
    mov rdi, 1              
    syscall

    mov rax, 60             
    xor rdi, rdi            
    syscall