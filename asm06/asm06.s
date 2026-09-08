section .bss
    buf resb 32

section .text
global _start

_start:
    cmp qword [rsp], 3
    jne error

    mov rsi, [rsp + 16]
    call parse_number
    jc error
    mov r12, rax

    mov rsi, [rsp + 24]
    call parse_number
    jc error

addition:
    add rax, r12
    test rax, rax
    jns positive
    neg rax
    mov r11, 1
    jmp convert_start

positive:
    xor r11, r11

convert_start:
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

    cmp r11, 0
    je write
    dec rsi
    mov byte [rsi], '-'
    inc rcx

write:
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall

parse_number:
    xor rax, rax
    xor rcx, rcx
    xor r8, r8

    cmp byte [rsi], '-'
    jne parse_digit
    inc rsi
    mov rcx, 1

parse_digit:
    movzx rdx, byte [rsi]
    cmp dl, 0
    je parse_end
    cmp dl, '0'
    jb parse_invalid
    cmp dl, '9'
    ja parse_invalid
    imul rax, rax, 10
    sub rdx, '0'
    add rax, rdx
    inc r8
    inc rsi
    jmp parse_digit

parse_end:
    cmp r8, 0
    je parse_invalid
    cmp rcx, 0
    je parse_valid
    neg rax

parse_valid:
    clc
    ret

parse_invalid:
    stc
    ret

error:
    mov rax, 60
    mov rdi, 1
    syscall