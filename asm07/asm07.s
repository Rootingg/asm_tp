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
    xor r8, r8
    xor r9, r9

.parse:
    movzx rax, byte [rsi]
    cmp al, 10
    je .parsed
    cmp al, '0'
    jb .bad
    cmp al, '9'
    ja .bad
    sub rax, '0'
    imul r8, r8, 10
    add r8, rax
    inc r9
    inc rsi
    jmp .parse

.parsed:
    cmp r9, 0
    je .bad
    cmp r8, 2
    jb .not_prime
    je .prime
    test r8, 1
    jz .not_prime

    mov r9, 3

.test_divisor:
    cmp r9, r8
    jae .prime
    mov rax, r8
    xor rdx, rdx
    div r9
    cmp rdx, 0
    je .not_prime
    add r9, 2
    jmp .test_divisor

.prime:
    mov rdi, 0
    jmp .exit

.not_prime:
    mov rdi, 1
    jmp .exit

.bad:
    mov rdi, 2

.exit:
    mov rax, 60       
    syscall