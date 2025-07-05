; maxheap.asm
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite

section .data
    fmt_d      db "%d",0
    fmt_out    db "%d ",0
    fmt_nl     db 10,0

section .bss
    n           resd 1
    heap        resd 400
    heap_size   resd 1

section .text
    extern scanf, printf
    global main

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; read n
    lea     rdi, [rel fmt_d]
    lea     rsi, [rel n]
    xor     eax, eax
    call    scanf

    ; init heap_size=0
    mov     dword [rel heap_size], 0

    ; insert n values
    xor     r12d, r12d
.read_loop:
    cmp     r12d, dword [rel n]
    jge     .extract

    lea     rdi, [rel fmt_d]
    lea     rsi, [rbp-4]
    xor     eax, eax
    call    scanf
    mov     eax, [rbp-4]
    call    insert_heap

    inc     r12d
    jmp     .read_loop

.extract:
    xor     r12d, r12d
.print_loop:
    cmp     r12d, dword [rel n]
    jge     .done

    call    extract_max
    lea     rdi, [rel fmt_out]
    mov     esi, eax
    xor     eax, eax
    call    printf

    inc     r12d
    jmp     .print_loop

.done:
    lea     rdi, [rel fmt_nl]
    xor     eax, eax
    call    printf

    xor     eax, eax
    leave
    ret

; insert_heap: bubble up if child > parent
; in: EAX = new value
insert_heap:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdx

    ; append to heap
    mov     ebx, dword [rel heap_size]
    mov     dword [rel heap + 4*rbx], eax
    inc     dword [rel heap_size]

    ; bubble-up
    mov     ecx, ebx
.up:
    test    ecx, ecx
    jz      .done_up
    mov     edx, ecx
    dec     edx
    shr     edx, 1

    mov     eax, dword [rel heap + 4*ecx]
    mov     ebx, dword [rel heap + 4*edx]
    cmp     eax, ebx
    jle     .done_up      ; if child ≤ parent, done
    ; swap child and parent
    mov     dword [rel heap + 4*ecx], ebx
    mov     dword [rel heap + 4*edx], eax
    mov     ecx, edx
    jmp     .up

.done_up:
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rbp
    ret

; extract_max: remove root, bubble down to restore max-heap
; out: EAX = max value
extract_max:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdx
    push    r8
    push    r9

    ; get max
    mov     eax, dword [rel heap]

    ; replace root with last element
    mov     ebx, dword [rel heap_size]
    dec     ebx
    mov     ecx, dword [rel heap + 4*ebx]
    mov     dword [rel heap], ecx
    dec     dword [rel heap_size]

    cmp     dword [rel heap_size], 0
    je      .done_down

    xor     ecx, ecx
.down:
    ; left = 2*i+1
    mov     edx, ecx
    shl     edx, 1
    inc     edx
    cmp     edx, dword [rel heap_size]
    jge     .done_down

    ; select larger child
    mov     r8d, edx
    mov     r9d, dword [rel heap + 4*edx]
    inc     edx
    cmp     edx, dword [rel heap_size]
    jge     .chk_parent
    mov     ebx, dword [rel heap + 4*edx]
    cmp     ebx, r9d
    jle     .chk_parent
    mov     r8d, edx
    mov     r9d, ebx

.chk_parent:
    mov     ebx, dword [rel heap + 4*ecx]
    cmp     ebx, r9d
    jge     .done_down      ; if parent ≥ child, done

    ; swap parent and child
    mov     dword [rel heap + 4*ecx], r9d
    mov     dword [rel heap + 4*r8], ebx
    mov     ecx, r8d
    jmp     .down

.done_down:
    pop     r9
    pop     r8
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rbp
    ret
