section .bss
    input_buffer resb 4096
    output_buffer resb 32

section .text
global _start

_start:
    xor r12, r12

read_input:
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 4096
    syscall
    test rax, rax
    jz print_count
    js exit_error

    mov r8, rax
    mov rsi, input_buffer

count_bytes:
    movzx rax, byte [rsi]
    inc rsi
    dec r8

    cmp al, 'a'
    je vowel
    cmp al, 'e'
    je vowel
    cmp al, 'i'
    je vowel
    cmp al, 'o'
    je vowel
    cmp al, 'u'
    je vowel
    cmp al, 'A'
    je vowel
    cmp al, 'E'
    je vowel
    cmp al, 'I'
    je vowel
    cmp al, 'O'
    je vowel
    cmp al, 'U'
    je vowel
    jmp next_byte

vowel:
    inc r12

next_byte:
    test r8, r8
    jnz count_bytes
    jmp read_input

print_count:
    mov rax, r12
    mov rsi, output_buffer
    add rsi, 32
    dec rsi
    mov byte [rsi], 10
    mov r10, 10
    xor rcx, rcx

convert:
    xor rdx, rdx
    div r10
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    test rax, rax
    jnz convert

    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    inc rdx
    syscall
    xor rdi, rdi
    jmp exit

exit_error:
    mov rdi, 1

exit:
    mov rax, 60
    syscall
