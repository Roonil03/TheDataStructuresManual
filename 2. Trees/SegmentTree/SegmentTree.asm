; segtree.asm
BITS 64
default rel
section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc, scanf, printf

section .data
    fmt_int db "%d",0
    fmt_ans db "%d ",0
    fmt_nl  db 10,0

section .bss
    n       resd 1           ; array size
    q       resd 1           ; number of queries
    arr     resq 1           ; pointer to original array (unused here)
    tree    resq 1           ; pointer to segment tree array

section .text
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Read n
    lea rdi, [fmt_int]
    lea rsi, [n]
    xor eax, eax
    call scanf               ; scanf("%d", &n) [2]

    ; Allocate tree array of size 2*n
    mov eax, [n]
    mov edi, eax
    shl edi, 3               ; bytes = 2*n*4
    call malloc
    mov [tree], rax

    ; Load leaf nodes: tree[n..2n-1]
    xor r12d, r12d           ; i = 0
.LOAD:
    cmp r12d, [n]
    jge .BUILD
    lea rdi, [fmt_int]
    lea rsi, [rbp-4]
    xor eax, eax
    call scanf               ; scanf("%d", temp)
    mov ecx, [rbp-4]
    mov rax, [tree]
    mov rsi, r12            ; index = n + i
    add rsi, [n]
    mov [rax + 4*rsi], ecx ; tree[n+i] = value
    inc r12d
    jmp .LOAD

.BUILD:
    mov r12d, [n]
    dec r12d                 ; i = n-1
.BUILD_LOOP:
    cmp r12d, 1
    jl .READ_Q
    mov rax, [tree]
    mov rsi, r12
    shl rsi, 1               ; left child index = 2*i
    mov ebx, [rax + 4*rsi]
    inc rsi                  ; right child index = 2*i+1
    mov edx, [rax + 4*rsi]
    add ebx, edx
    mov [rax + 4*r12], ebx   ; tree[i] = left + right
    dec r12d
    jmp .BUILD_LOOP

.READ_Q:
    lea rdi, [fmt_int]
    lea rsi, [q]
    xor eax, eax
    call scanf               ; scanf("%d", &q)

    xor r12d, r12d           ; query counter = 0
.QUERY_LOOP:
    cmp r12d, [q]
    jge .DONE
    lea rdi, [fmt_int]
    lea rsi, [rbp-8]
    xor eax, eax
    call scanf               ; read l
    lea rdi, [fmt_int]
    lea rsi, [rbp-4]
    xor eax, eax
    call scanf               ; read r

    mov edi, [rbp-8]         ; l
    mov esi, [rbp-4]         ; r
    call query_range         ; result in eax [1]

    lea rdi, [fmt_ans]
    mov esi, eax
    xor eax, eax
    call printf

    inc r12d
    jmp .QUERY_LOOP

.DONE:
    lea rdi, [fmt_nl]
    xor eax, eax
    call printf

    leave
    ret

; query_range(l, r): returns sum of [l, r]
query_range:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    mov r12d, edi            ; l
    mov r13d, esi            ; r
    add r12d, [n]            ; l += n
    add r13d, [n]            ; r += n
    inc r13d                 ; exclusive boundary
    xor eax, eax             ; sum = 0

.Q_LOOP:
    cmp r12d, r13d
    jge .Q_DONE
    test r12d, 1
    jz .CHK_R
    mov rbx, [tree]
    add eax, [rbx + 4*r12]
    inc r12d

.CHK_R:
    test r13d, 1
    jz .SHIFT
    dec r13d
    mov rbx, [tree]
    add eax, [rbx + 4*r13]

.SHIFT:
    shr r12d, 1
    shr r13d, 1
    jmp .Q_LOOP

.Q_DONE:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
