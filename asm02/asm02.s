section .data
    message db "1337", 13, 10, 0   
    
section .bss
    input resb 5                   

section .text
global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 5
    syscall

    cmp word [input], 0x3234     
    jne exit
    cmp byte [input+2], 10         
    jne exit

    mov rax, 1
    mov rdi, 1
    mov rsi, message
    mov rdx, 6                      
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

exit:
    mov rax, 60
    mov rdi, 1
    syscall
