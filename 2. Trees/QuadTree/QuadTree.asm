; quadtree.asm
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    fmt_d       db "%d", 0
    fmt_point   db "(%d,%d) ", 0
    fmt_nl      db 10, 0
    fmt_nearest db "Nearest to (%d,%d): (%d,%d)", 10, 0
    msg_tree    db "Points: ", 0

section .bss
    n           resd 1
    tree_nodes  resb 8000      ; 200 nodes max (40 bytes each)
    node_count  resd 1
    query_x     resd 1
    query_y     resd 1
    best_x      resd 1
    best_y      resd 1
    best_dist   resd 1

section .text
    extern scanf, printf
    global main

main:
    push    rbp
    mov     rbp, rsp
    push    r15
    sub     rsp, 40

    lea     r15, [rel tree_nodes]  ; Base address for nodes
    lea     rdi, [rel fmt_d]
    lea     rsi, [rel n]
    xor     eax, eax
    call    scanf

    mov     dword [rel node_count], 0
    xor     r14, r14              ; root = NULL
    xor     r12d, r12d

input_loop:
    cmp     r12d, dword [rel n]
    jge     query_input
    
    lea     rdi, [rel fmt_d]
    lea     rsi, [rbp-4]
    xor     eax, eax
    call    scanf
    
    lea     rdi, [rel fmt_d]
    lea     rsi, [rbp-8]
    xor     eax, eax
    call    scanf
    
    mov     edi, [rbp-4]
    mov     esi, [rbp-8]
    mov     rdx, r14
    call    insert_point
    mov     r14, rax
    
    inc     r12d
    jmp     input_loop

query_input:
    lea     rdi, [rel msg_tree]
    xor     eax, eax
    call    printf
    
    mov     rdi, r14
    call    print_tree
    
    lea     rdi, [rel fmt_nl]
    xor     eax, eax
    call    printf
    
    lea     rdi, [rel fmt_d]
    lea     rsi, [rel query_x]
    xor     eax, eax
    call    scanf
    
    lea     rdi, [rel fmt_d]
    lea     rsi, [rel query_y]
    xor     eax, eax
    call    scanf
    
    mov     dword [rel best_dist], 0x7fffffff
    mov     rdi, r14
    call    find_nearest
    
    lea     rdi, [rel fmt_nearest]
    mov     esi, [rel query_x]
    mov     edx, [rel query_y]
    mov     ecx, [rel best_x]
    mov     r8d, [rel best_y]
    xor     eax, eax
    call    printf

    add     rsp, 40
    pop     r15
    xor     eax, eax
    leave
    ret

insert_point:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14
    
    mov     r12d, edi
    mov     r13d, esi
    mov     r14, rdx
    
    test    r14, r14
    jnz     has_node
    
    ; Create new node
    mov     eax, dword [rel node_count]
    inc     dword [rel node_count]
    mov     ebx, 40
    mul     ebx
    lea     rax, [r15 + rax]     ; Use R15 base
    
    mov     [rax], r12d           ; x
    mov     [rax + 4], r13d       ; y
    mov     qword [rax + 8], 0    ; nw
    mov     qword [rax + 16], 0   ; ne
    mov     qword [rax + 24], 0   ; sw
    mov     qword [rax + 32], 0   ; se
    jmp     insert_end

has_node:
    mov     eax, [r14]            ; node x
    mov     ebx, [r14 + 4]        ; node y
    
    cmp     r12d, eax
    jl      west_side
    cmp     r13d, ebx
    jl      go_se
    
    ; NE quadrant
    mov     rdi, r12
    mov     rsi, r13
    mov     rdx, [r14 + 16]
    call    insert_point
    mov     [r14 + 16], rax
    jmp     ret_node

go_se:
    ; SE quadrant
    mov     rdi, r12
    mov     rsi, r13
    mov     rdx, [r14 + 32]
    call    insert_point
    mov     [r14 + 32], rax
    jmp     ret_node

west_side:
    cmp     r13d, ebx
    jl      go_sw
    
    ; NW quadrant
    mov     rdi, r12
    mov     rsi, r13
    mov     rdx, [r14 + 8]
    call    insert_point
    mov     [r14 + 8], rax
    jmp     ret_node

go_sw:
    ; SW quadrant
    mov     rdi, r12
    mov     rsi, r13
    mov     rdx, [r14 + 24]
    call    insert_point
    mov     [r14 + 24], rax

ret_node:
    mov     rax, r14

insert_end:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

print_tree:
    push    rbp
    mov     rbp, rsp
    push    rbx
    
    test    rdi, rdi
    jz      print_end
    
    mov     rbx, rdi
    
    lea     rdi, [rel fmt_point]
    mov     esi, [rbx]
    mov     edx, [rbx + 4]
    xor     eax, eax
    call    printf
    
    mov     rdi, [rbx + 8]        ; nw
    call    print_tree
    
    mov     rdi, [rbx + 16]       ; ne
    call    print_tree
    
    mov     rdi, [rbx + 24]       ; sw
    call    print_tree
    
    mov     rdi, [rbx + 32]       ; se
    call    print_tree

print_end:
    pop     rbx
    pop     rbp
    ret

find_nearest:
    push    rbp
    mov     rbp, rsp
    push    rbx
    
    test    rdi, rdi
    jz      find_end
    
    mov     rbx, rdi
    
    mov     eax, [rel query_x]
    sub     eax, [rbx]
    imul    eax, eax
    
    mov     ecx, [rel query_y]
    sub     ecx, [rbx + 4]
    imul    ecx, ecx
    
    add     eax, ecx
    
    cmp     eax, [rel best_dist]
    jge     no_update
    
    mov     [rel best_dist], eax
    mov     ecx, [rbx]
    mov     [rel best_x], ecx
    mov     ecx, [rbx + 4]
    mov     [rel best_y], ecx

no_update:
    mov     rdi, [rbx + 8]        ; nw
    call    find_nearest
    
    mov     rdi, [rbx + 16]       ; ne
    call    find_nearest
    
    mov     rdi, [rbx + 24]       ; sw
    call    find_nearest
    
    mov     rdi, [rbx + 32]       ; se
    call    find_nearest

find_end:
    pop     rbx
    pop     rbp
    ret
