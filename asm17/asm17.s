section .bss
    align 8
    statbuf resb 256

section .text
    global _start

_start:
    cmp     qword [rsp], 2
    jne     .usage

.open:
    mov     rdi, [rsp + 16]
    mov     rsi, 2
    xor     edx, edx
    mov     rax, 2
    syscall
    cmp     rax, -4
    je      .open
    test    rax, rax
    js      .error
    mov     r12, rax

.stat:
    mov     rax, 5
    mov     rdi, r12
    mov     rsi, statbuf
    syscall
    cmp     rax, -4
    je      .stat
    test    rax, rax
    js      .close_error
    mov     r13, [statbuf + 48]
    cmp     r13, 4
    jb      .close_error

.map:
    xor     edi, edi
    mov     rsi, r13
    mov     rdx, 3
    mov     r10, 1
    mov     r8, r12
    xor     r9d, r9d
    mov     rax, 9
    syscall
    cmp     rax, -4
    je      .map
    cmp     rax, -4096
    ja      .close_error
    mov     r14, rax

    mov     rbx, r13
    sub     rbx, 3
    xor     rcx, rcx
    xor     r15d, r15d

.scan:
    cmp     rcx, rbx
    jae     .scanned
    cmp     dword [r14 + rcx], 0x37333331
    jne     .next
    mov     dword [r14 + rcx], 0x4B433448
    mov     r15d, 1
.next:
    inc     rcx
    jmp     .scan

.scanned:
    test    r15d, r15d
    jz      .unmap_miss

.sync:
    mov     rax, 26
    mov     rdi, r14
    mov     rsi, r13
    mov     rdx, 4
    syscall
    cmp     rax, -4
    je      .sync
    test    rax, rax
    js      .unmap_miss

.unmap:
    mov     rax, 11
    mov     rdi, r14
    mov     rsi, r13
    syscall
    cmp     rax, -4
    je      .unmap
    test    rax, rax
    js      .close_error

.close:
    mov     rax, 3
    mov     rdi, r12
    syscall
    cmp     rax, -4
    je      .close
    xor     edi, edi
    jmp     .exit

.unmap_miss:
    mov     rax, 11
    mov     rdi, r14
    mov     rsi, r13
    syscall
    cmp     rax, -4
    je      .unmap_miss

.close_error:
    mov     rax, 3
    mov     rdi, r12
    syscall
    cmp     rax, -4
    je      .close_error

.error:
    mov     edi, 1
    jmp     .exit

.usage:
    mov     edi, 2

.exit:
    mov     rax, 60
    syscall
