section .data
    align 8
    tv      dq 1
            dq 0

    addr:
        dw  2
        dw  0x3905
        db  127, 0, 0, 1
        times 8 db 0

    req     db "1337"

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

.setopt:
    mov     rax, 54
    mov     rdi, r12
    mov     rsi, 1
    mov     rdx, 20
    lea     r10, [tv]
    mov     r8, 16
    syscall
    cmp     rax, -4
    je      .setopt
    test    rax, rax
    js      .close_fail

.send:
    mov     rax, 44
    mov     rdi, r12
    lea     rsi, [req]
    mov     rdx, 4
    xor     r10d, r10d
    lea     r8, [addr]
    mov     r9, 16
    syscall
    cmp     rax, -4
    je      .send
    cmp     rax, 4
    jne     .close_fail

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
    js      .close_fail
    mov     r13, rax

    xor     r14, r14
.write:
    cmp     r14, r13
    jae     .close_ok
    mov     rax, 1
    mov     edi, 1
    lea     rsi, [buf + r14]
    mov     rdx, r13
    sub     rdx, r14
    syscall
    cmp     rax, -4
    je      .write
    test    rax, rax
    jle     .close_fail
    add     r14, rax
    jmp     .write

.close_ok:
    mov     rax, 3
    mov     rdi, r12
    syscall
    cmp     rax, -4
    je      .close_ok
    xor     edi, edi
    jmp     .exit

.close_fail:
    mov     rax, 3
    mov     rdi, r12
    syscall
    cmp     rax, -4
    je      .close_fail

.fail:
    mov     edi, 1

.exit:
    mov     rax, 60
    syscall
