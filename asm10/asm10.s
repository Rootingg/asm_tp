section .bss
    buffer resb 32

section .text
global _start

_start:
    cmp qword [rsp], 4
    jne wrong_arguments

    mov rsi, [rsp + 16]
    call parse_number
    jc invalid_number
    mov r12, rax

    mov rsi, [rsp + 24]
    call parse_number
    jc invalid_number
    cmp rax, r12
    cmovg r12, rax

    mov rsi, [rsp + 32]
    call parse_number
    jc invalid_number
    cmp rax, r12
    cmovg r12, rax

    mov rax, r12
    mov rsi, buffer
    add rsi, 32
    dec rsi
    mov byte [rsi], 10
    mov r10, 10
    xor rcx, rcx

    test rax, rax
    jns convert_number
    neg rax
    mov r11, 1
    jmp convert_digits

convert_number:
    xor r11, r11

convert_digits:
    xor rdx, rdx
    div r10
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    test rax, rax
    jnz convert_digits

    test r11, r11
    jz write_result
    dec rsi
    mov byte [rsi], '-'
    inc rcx

write_result:
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    inc rdx
    syscall
    xor rdi, rdi
    jmp exit

parse_number:
    xor rax, rax
    xor rcx, rcx
    xor r8, r8

    cmp byte [rsi], '-'
    jne parse_digits
    inc rsi
    mov rcx, 1

parse_digits:
    movzx rdx, byte [rsi]
    test dl, dl
    jz parse_end
    cmp dl, '0'
    jb parse_invalid
    cmp dl, '9'
    ja parse_invalid
    imul rax, rax, 10
    sub dl, '0'
    add rax, rdx
    inc r8
    inc rsi
    jmp parse_digits

parse_end:
    test r8, r8
    jz parse_invalid
    test rcx, rcx
    jz parse_valid
    neg rax

parse_valid:
    clc
    ret

parse_invalid:
    stc
    ret

wrong_arguments:
    mov rdi, 2
    jmp exit

invalid_number:
    mov rdi, 1

exit:
    mov rax, 60
    syscall
