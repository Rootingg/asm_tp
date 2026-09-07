section .bss
    buf resb 32

section .text
global _start

_start:
    mov rsi, [rsp + 16]
    xor r8, r8

parse_arg1:
    movzx rax, byte [rsi]
    cmp al, 0
    je parse_arg2
    sub rax, '0'
    imul r8, r8, 10
    add r8, rax
    inc rsi
    jmp parse_arg1

parse_arg2:
    mov rsi, [rsp + 24]
    xor r9, r9

parse_arg2_loop:
    movzx rax, byte [rsi]
    cmp al, 0
    je addition
    sub rax, '0'
    imul r9, r9, 10
    add r9, rax
    inc rsi
    jmp parse_arg2_loop
addition:
    add r8, r9
    mov rax, r8
    lea rsi, [buf + 32]
    dec rsi
    mov byte [rsi], 10     
    xor rcx, rcx
    inc rcx                
    mov r10, 10

convert:
    xor rdx, rdx
    div r10
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    cmp rax, 0
    jne convert

    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall