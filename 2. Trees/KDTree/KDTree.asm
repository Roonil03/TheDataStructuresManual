; kdtree.asm - 2D KD-Tree
BITS 64
default rel

section .data
    fmt_d       db "%d", 0
    fmt_point   db "(%d,%d) ", 0
    fmt_nl      db 10, 0
    fmt_nearest db "Nearest to (%d,%d): (%d,%d)", 10, 0
    msg_tree    db "Tree: ", 0

section .bss
    n           resd 1
    tree_nodes  resb 3200      ; 100 nodes max
    node_count  resd 1
    query_x     resd 1
    query_y     resd 1
    best_x      resd 1
    best_y      resd 1
    best_dist   resd 1

section .text
    extern scanf, printf
    global main

; Node: x(4) y(4) left(8) right(8) depth(4) pad(4) = 32 bytes

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; Read n
    lea     rdi, [rel fmt_d]
    lea     rsi, [rel n]
    xor     eax, eax
    call    scanf

    ; Initialize
    mov     dword [rel node_count], 0
    xor     r14, r14              ; root = NULL
    xor     r12d, r12d            ; counter

input_loop:
    cmp     r12d, dword [rel n]
    jge     query_input
    
    ; Read point
    lea     rdi, [rel fmt_d]
    lea     rsi, [rbp-4]
    xor     eax, eax
    call    scanf
    
    lea     rdi, [rel fmt_d]
    lea     rsi, [rbp-8]
    xor     eax, eax
    call    scanf
    
    ; Insert
    mov     edi, [rbp-4]
    mov     esi, [rbp-8]
    mov     rdx, r14
    xor     ecx, ecx
    call    insert_node
    mov     r14, rax
    
    inc     r12d
    jmp     input_loop

query_input:
    ; Print tree
    lea     rdi, [rel msg_tree]
    xor     eax, eax
    call    printf
    
    mov     rdi, r14
    call    print_tree
    
    lea     rdi, [rel fmt_nl]
    xor     eax, eax
    call    printf
    
    ; Read query
    lea     rdi, [rel fmt_d]
    lea     rsi, [rel query_x]
    xor     eax, eax
    call    scanf
    
    lea     rdi, [rel fmt_d]
    lea     rsi, [rel query_y]
    xor     eax, eax
    call    scanf
    
    ; Find nearest
    mov     dword [rel best_dist], 0x7fffffff
    mov     rdi, r14
    call    find_nearest
    
    ; Print result
    lea     rdi, [rel fmt_nearest]
    mov     esi, [rel query_x]
    mov     edx, [rel query_y]
    mov     ecx, [rel best_x]
    mov     r8d, [rel best_y]
    xor     eax, eax
    call    printf

    xor     eax, eax
    leave
    ret

; Insert node
insert_node:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14
    
    mov     r12d, edi             ; x
    mov     r13d, esi             ; y
    mov     r14, rdx              ; current
    
    test    r14, r14
    jnz     has_node
    
    ; Create node
    mov     eax, dword [rel node_count]
    inc     dword [rel node_count]
    mov     ebx, 32
    mul     ebx
    lea     rax, [rel tree_nodes + rax]
    
    mov     [rax], r12d           ; x
    mov     [rax + 4], r13d       ; y
    mov     qword [rax + 8], 0    ; left
    mov     qword [rax + 16], 0   ; right
    mov     [rax + 24], ecx       ; depth
    jmp     insert_end

has_node:
    mov     ebx, ecx
    and     ebx, 1                ; dimension
    
    test    ebx, ebx
    jnz     comp_y
    
    ; Compare x
    cmp     r12d, [r14]
    jl      go_left
    
    mov     rdi, r12
    mov     rsi, r13
    mov     rdx, [r14 + 16]
    inc     ecx
    call    insert_node
    mov     [r14 + 16], rax
    jmp     ret_node

comp_y:
    ; Compare y
    cmp     r13d, [r14 + 4]
    jl      go_left
    
    mov     rdi, r12
    mov     rsi, r13
    mov     rdx, [r14 + 16]
    inc     ecx
    call    insert_node
    mov     [r14 + 16], rax
    jmp     ret_node

go_left:
    mov     rdi, r12
    mov     rsi, r13
    mov     rdx, [r14 + 8]
    inc     ecx
    call    insert_node
    mov     [r14 + 8], rax

ret_node:
    mov     rax, r14

insert_end:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

; Print tree
print_tree:
    push    rbp
    mov     rbp, rsp
    push    rbx
    
    test    rdi, rdi
    jz      print_end
    
    mov     rbx, rdi
    
    mov     rdi, [rbx + 8]
    call    print_tree
    
    lea     rdi, [rel fmt_point]
    mov     esi, [rbx]
    mov     edx, [rbx + 4]
    xor     eax, eax
    call    printf
    
    mov     rdi, [rbx + 16]
    call    print_tree

print_end:
    pop     rbx
    pop     rbp
    ret

; Find nearest neighbor
find_nearest:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    
    test    rdi, rdi
    jz      find_end
    
    mov     rbx, rdi
    
    ; Calculate distance squared
    mov     eax, [rel query_x]
    sub     eax, [rbx]
    imul    eax, eax              ; dx^2
    
    mov     ecx, [rel query_y]
    sub     ecx, [rbx + 4]
    imul    ecx, ecx              ; dy^2
    
    add     eax, ecx              ; distance^2
    
    ; Update best if better
    cmp     eax, [rel best_dist]
    jge     no_update
    
    mov     [rel best_dist], eax
    mov     ecx, [rbx]
    mov     [rel best_x], ecx
    mov     ecx, [rbx + 4]
    mov     [rel best_y], ecx

no_update:
    ; Recursively search children
    mov     rdi, [rbx + 8]
    call    find_nearest
    
    mov     rdi, [rbx + 16]
    call    find_nearest

find_end:
    pop     r12
    pop     rbx
    pop     rbp
    ret
