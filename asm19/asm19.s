section .data
    banner      db "Listening on port 1337", 10
    banner_len  equ $ - banner

    path        db "messages", 0

    addr:
        dw  2
        dw  0x3905
        dd  0
        times 8 db 0

section .bss
    buf resb 65536

section .text
    global _start

_start:
.socket:
    mov     rax, 41
    mov     rdi, 2
    mov     rsi, 2
    xor     edx, edx
    syscall
    cmp     rax, -4
    je      .socket
    test    rax, rax
    js      .fail
    mov     r12, rax

.bind:
    mov     rax, 49
    mov     rdi, r12
    lea     rsi, [addr]
    mov     rdx, 16
    syscall
    cmp     rax, -4
    je      .bind
    test    rax, rax
    js      .close_sock

.open:
    lea     rdi, [path]
    mov     rsi, 0x241
    mov     rdx, 0o644
    mov     rax, 2
    syscall
    cmp     rax, -4
    je      .open
    test    rax, rax
    js      .close_sock
    mov     r15, rax

    lea     rsi, [banner]
    mov     rdx, banner_len
.banner:
    mov     edi, 1
    mov     rax, 1
    syscall
    cmp     rax, -4
    je      .banner
    test    rax, rax
    jle     .close_both
    add     rsi, rax
    sub     rdx, rax
    jnz     .banner

.recv:
    mov     rax, 45
    mov     rdi, r12
    lea     rsi, [buf]
    mov     rdx, 65536
    xor     r10d, r10d
    xor     r8, r8
    xor     r9, r9
    syscall
    cmp     rax, -4
    je      .recv
    test    rax, rax
    js      .close_both
    mov     rbx, rax

    lea     rsi, [buf]
    mov     rdx, rbx
.log:
    test    rdx, rdx
    jz      .recv
    mov     rax, 1
    mov     rdi, r15
    syscall
    cmp     rax, -4
    je      .log
    test    rax, rax
    jle     .close_both
    add     rsi, rax
    sub     rdx, rax
    jnz     .log
    jmp     .recv

.close_both:
    mov     rax, 3
    mov     rdi, r15
    syscall
    cmp     rax, -4
    je      .close_both

.close_sock:
    mov     rax, 3
    mov     rdi, r12
    syscall
    cmp     rax, -4
    je      .close_sock

.fail:
    mov     edi, 1
    mov     rax, 60
    syscall
