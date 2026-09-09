section .bss
    buf resb 32

section .text
global _start

_start:
    mov rsi, [rsp + 16]
    xor r8, r8

    movzx rax, byte [rsi]
    cmp al, '-'
    je exit                 

parse_n:
    movzx rax, byte [rsi]
    cmp al, 0
    je got_n
    cmp al, '0'
    jb exit                
    cmp al, '9'
    ja exit
    sub rax, '0'
    imul r8, r8, 10
    add r8, rax
    inc rsi
    jmp parse_n

got_n:
    xor r9, r9
    cmp r8, 2
    jb print                

    xor rcx, rcx
sum_loop:
    inc rcx
    cmp rcx, r8
    je print
    add r9, rcx
    jmp sum_loop

print:
    mov rax, r9
    mov rsi, buf
    add rsi, 32
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

exit:
    mov rax, 60
    xor rdi, rdi
    syscall