section .bss
    buf resb 1

section .text
global _start

_start:
    xor r8, r8
    xor r9, r9
    xor r12, r12

read:
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 1
    syscall
    test rax, rax
    js .bad
    jz .parsed

    movzx rax, byte [buf]
    cmp al, 10
    je .parsed
    cmp al, '-'
    jne .check_digit
    cmp r9, 0
    jne .bad
    test r12, r12
    jnz .bad
    mov r12, 1
    jmp read

.check_digit:
    cmp al, '0'
    jb .bad
    cmp al, '9'
    ja .bad
    sub rax, '0'
    mov r10, 922337203685477580
    cmp r8, r10
    ja .bad
    jne .add_digit
    test r12, r12
    jnz .neg_limit
    cmp rax, 7
    ja .bad
    jmp .add_digit

.neg_limit:
    cmp rax, 8
    ja .bad

.add_digit:
    imul r8, r8, 10
    add r8, rax
    inc r9
    jmp read

.parsed:
    cmp r9, 0
    je .bad
    test r12, r12
    jnz .not_prime
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