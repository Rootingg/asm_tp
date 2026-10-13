section .bss
    buf resb 4096

section .text
    global _start

_start:
    cmp     qword [rsp], 2
    jne     .usage

    mov     rsi, [rsp + 16]
    call    parse_number
    jc      .invalid

    mov     rcx, 26
    cqo
    idiv    rcx
    test    rdx, rdx
    jns     .shift_ready
    add     rdx, 26
.shift_ready:
    mov     r12, rdx

.read:
    xor     edi, edi
    mov     rsi, buf
    mov     rdx, 4096
    mov     rax, 0
    syscall
    cmp     rax, -4
    je      .read
    test    rax, rax
    jz      .success
    js      .invalid
    mov     r13, rax
    xor     r14, r14

.shift:
    cmp     r14, r13
    jae     .write_setup
    movzx   eax, byte [buf + r14]

    cmp     al, 'a'
    jb      .upper
    cmp     al, 'z'
    ja      .next
    sub     al, 'a'
    add     al, r12b
    cmp     al, 26
    jb      .store_lower
    sub     al, 26
.store_lower:
    add     al, 'a'
    mov     [buf + r14], al
    jmp     .next

.upper:
    cmp     al, 'A'
    jb      .next
    cmp     al, 'Z'
    ja      .next
    sub     al, 'A'
    add     al, r12b
    cmp     al, 26
    jb      .store_upper
    sub     al, 26
.store_upper:
    add     al, 'A'
    mov     [buf + r14], al

.next:
    inc     r14
    jmp     .shift

.write_setup:
    xor     r14, r14
.write:
    cmp     r14, r13
    jae     .read
    mov     rax, 1
    mov     edi, 1
    lea     rsi, [buf + r14]
    mov     rdx, r13
    sub     rdx, r14
    syscall
    cmp     rax, -4
    je      .write
    test    rax, rax
    jle     .invalid
    add     r14, rax
    jmp     .write

.success:
    xor     edi, edi
    jmp     .exit

.usage:
    mov     edi, 2
    jmp     .exit

.invalid:
    mov     edi, 1

.exit:
    mov     rax, 60
    syscall

parse_number:
    xor     rax, rax
    xor     rcx, rcx
    xor     r8, r8
    mov     r9, 922337203685477580

    cmp     byte [rsi], '-'
    jne     .digits
    inc     rsi
    mov     rcx, 1

.digits:
    movzx   rdx, byte [rsi]
    test    dl, dl
    jz      .done
    cmp     dl, '0'
    jb      .bad
    cmp     dl, '9'
    ja      .bad
    sub     dl, '0'
    cmp     rax, r9
    ja      .bad
    jne     .add
    test    rcx, rcx
    jnz     .neg_limit
    cmp     dl, 7
    ja      .bad
    jmp     .add

.neg_limit:
    cmp     dl, 8
    ja      .bad

.add:
    imul    rax, rax, 10
    add     rax, rdx
    inc     r8
    inc     rsi
    jmp     .digits

.done:
    test    r8, r8
    jz      .bad
    test    rcx, rcx
    jz      .ok
    neg     rax

.ok:
    clc
    ret

.bad:
    stc
    ret
