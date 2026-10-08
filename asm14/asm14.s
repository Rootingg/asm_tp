section .data
    msg     db "Hello Universe!"
    msg_len equ $ - msg

section .text
    global _start

_start:
    cmp     qword [rsp], 2
    jne     .bad_args

    mov     rdi, [rsp + 16]
    mov     rsi, 0x241
    mov     rdx, 0o644
    mov     rax, 2
    syscall
    test    rax, rax
    js      .error

    mov     r12, rax

    lea     rsi, [rel msg]
    mov     rdx, msg_len
.write_loop:
    mov     rdi, r12
    mov     rax, 1
    syscall
    cmp     rax, -4
    je      .write_loop
    test    rax, rax
    js      .close_error
    jz      .close_error
    add     rsi, rax
    sub     rdx, rax
    jnz     .write_loop

    mov     rdi, r12
    mov     rax, 3
    syscall
    test    rax, rax
    js      .error

    xor     edi, edi
    jmp     .exit

.close_error:
    mov     rdi, r12
    mov     rax, 3
    syscall
.error:
    mov     edi, 1
    jmp     .exit

.bad_args:
    mov     edi, 2

.exit:
    mov     rax, 60
    syscall