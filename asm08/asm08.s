section .bss
    buf resb 32

section .text
global _start

_start:
    cmp qword [rsp], 2
    jne usage

    mov rsi, [rsp + 16]
    xor r8, r8
    xor r9, r9
    xor r12, r12

    cmp byte [rsi], '-'
    jne parse_n
    inc rsi
    mov r12, 1

parse_n:
    movzx rax, byte [rsi]
    cmp al, 0
    je got_n
    cmp al, '0'
    jb error
    cmp al, '9'
    ja error
    sub rax, '0'
    mov r10, 922337203685477580
    cmp r8, r10
    ja error
    jne add_digit
    test r12, r12
    jnz neg_limit
    cmp rax, 7
    ja error
    jmp add_digit

neg_limit:
    cmp rax, 8
    ja error

add_digit:
    imul r8, r8, 10
    add r8, rax
    inc r9
    inc rsi
    jmp parse_n

got_n:
    test r9, r9
    jz error
    test r12, r12
    jnz empty_range

    xor r9, r9
    cmp r8, 2
    jb print

    mov rax, r8
    test rax, 1
    jnz odd_n
    shr rax, 1
    mov rcx, r8
    dec rcx
    mul rcx
    mov r9, rax
    jmp print

odd_n:
    mov rcx, r8
    dec rcx
    shr rcx, 1
    mul rcx
    mov r9, rax
    jmp print

empty_range:
    xor r9, r9

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
    jmp done

usage:
    mov rax, 60
    mov rdi, 2
    syscall

error:
    mov rax, 60
    mov rdi, 1
    syscall

done:
    mov rax, 60
    xor rdi, rdi
    syscall
