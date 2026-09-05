section .bss
    buf resb 16

section .text
global _start

_start:
    mov rax, 0         
    mov rdi, 0          
    mov rsi, buf
    mov rdx, 16
    syscall

    mov rsi, buf
    cmp byte [rsi], '-'
    jne .digits
    inc rsi           

.digits:
    mov al, [rsi]
    cmp al, '0'
    jb .bad
    cmp al, '9'
    ja .bad

.loop:
    inc rsi
    mov al, [rsi]
    cmp al, 10          
    je .end
    cmp al, '0'
    jb .bad
    cmp al, '9'
    ja .bad
    jmp .loop

.end:
    mov al, [rsi-1]    
    and al, 1          
    mov rdi, 0
    mov dil, al         
    jmp .exit

.bad:
    mov rdi, 2

.exit:
    mov rax, 60       
    syscall