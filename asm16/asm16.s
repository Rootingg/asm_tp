section .bss
    align 8
    hdr     resb 64
    statbuf resb 256

section .text
    global _start

_start:
    cmp     qword [rsp], 2
    jne     .usage

.open:
    mov     rdi, [rsp + 16]
    xor     esi, esi
    xor     edx, edx
    mov     rax, 2
    syscall
    cmp     rax, -4
    je      .open
    test    rax, rax
    js      .usage
    mov     r12, rax

    xor     r13, r13
.read_hdr:
    mov     rax, 0
    mov     rdi, r12
    lea     rsi, [hdr + r13]
    mov     rdx, 64
    sub     rdx, r13
    syscall
    cmp     rax, -4
    je      .read_hdr
    test    rax, rax
    js      .unreadable
    jz      .not_elf
    add     r13, rax
    cmp     r13, 64
    jb      .read_hdr

    cmp     dword [hdr], 0x464C457F
    jne     .not_elf
    cmp     byte [hdr + 4], 2
    jne     .not_elf
    cmp     byte [hdr + 5], 1
    jne     .not_elf
    cmp     byte [hdr + 6], 1
    jne     .not_elf

    movzx   eax, word [hdr + 16]
    cmp     eax, 1
    jb      .not_elf
    cmp     eax, 4
    ja      .not_elf
    cmp     word [hdr + 18], 62
    jne     .not_elf
    cmp     dword [hdr + 20], 1
    jne     .not_elf
    cmp     word [hdr + 52], 64
    jne     .not_elf

.stat:
    mov     rax, 5
    mov     rdi, r12
    mov     rsi, statbuf
    syscall
    cmp     rax, -4
    je      .stat
    test    rax, rax
    js      .unreadable
    mov     r13, [statbuf + 48]
    cmp     r13, 64
    jb      .not_elf

    movzx   ecx, word [hdr + 56]
    test    ecx, ecx
    jz      .sections
    cmp     word [hdr + 54], 56
    jne     .not_elf
    cmp     ecx, 0xffff
    je      .sections
    mov     rax, [hdr + 32]
    cmp     rax, 64
    jb      .not_elf
    imul    rdx, rcx, 56
    mov     rbx, r13
    sub     rbx, rax
    jb      .not_elf
    cmp     rdx, rbx
    ja      .not_elf

.sections:
    movzx   ecx, word [hdr + 60]
    test    ecx, ecx
    jz      .ext_sections
    cmp     word [hdr + 58], 64
    jne     .not_elf
    movzx   eax, word [hdr + 62]
    cmp     eax, 0xffff
    je      .section_range
    cmp     eax, ecx
    jae     .not_elf
.section_range:
    mov     rax, [hdr + 40]
    cmp     rax, 64
    jb      .not_elf
    imul    rdx, rcx, 64
    mov     rbx, r13
    sub     rbx, rax
    jb      .not_elf
    cmp     rdx, rbx
    ja      .not_elf
    jmp     .ok

.ext_sections:
    mov     rax, [hdr + 40]
    test    rax, rax
    jz      .ok
    cmp     word [hdr + 58], 64
    jne     .not_elf
    cmp     rax, 64
    jb      .not_elf
    mov     rbx, r13
    sub     rbx, rax
    jb      .not_elf
    cmp     rbx, 64
    jb      .not_elf

.ok:
    xor     edi, edi
    jmp     .close_exit

.not_elf:
    mov     edi, 1
    jmp     .close_exit

.unreadable:
    mov     edi, 2

.close_exit:
    mov     r15d, edi
.close:
    mov     rax, 3
    mov     rdi, r12
    syscall
    cmp     rax, -4
    je      .close
    mov     edi, r15d
    jmp     .exit

.usage:
    mov     edi, 2

.exit:
    mov     rax, 60
    syscall
