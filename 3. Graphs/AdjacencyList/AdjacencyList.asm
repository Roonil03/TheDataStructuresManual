section .data
    fmt_info:    db "Adjacency List (%d vertices):", 10, 0
    fmt_vertex:  db "  %d:", 0
    fmt_edge:    db " -> %d(w=%d)", 0
    fmt_nl:      db 10, 0
    fmt_has:     db "Edge %d->%d exists: %d", 10, 0
    fmt_outdeg:  db "Out-degree of %d: %d", 10, 0
    fmt_pass:    db "All tests passed.", 10, 0

ADJL_V       equ 0
ADJL_HEADS   equ 8
ADJL_SIZE    equ 16

NODE_DST     equ 0
NODE_WEIGHT  equ 4
NODE_NEXT    equ 8
NODE_SIZE    equ 16

section .text
    global main, adjlist_create, adjlist_add_edge, adjlist_has_edge, adjlist_out_degree, adjlist_print, adjlist_free
    extern malloc, calloc, free, printf

adjlist_create:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 16

    mov r12d, edi

    mov edi, ADJL_SIZE
    call malloc
    mov rbx, rax
    mov dword [rbx + ADJL_V], r12d

    movsxd rdi, r12d
    mov esi, 8
    call calloc
    mov [rbx + ADJL_HEADS], rax

    mov rax, rbx
    add rsp, 16
    pop r12
    pop rbx
    pop rbp
    ret

adjlist_add_edge:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 16

    mov rbx, rdi
    mov r12d, esi
    mov r13d, edx
    mov r14d, ecx

    mov edi, NODE_SIZE
    call malloc

    mov dword [rax + NODE_DST], r13d
    mov dword [rax + NODE_WEIGHT], r14d

    mov rcx, [rbx + ADJL_HEADS]
    movsxd r8, r12d
    mov rdx, [rcx + r8*8]
    mov [rax + NODE_NEXT], rdx
    mov [rcx + r8*8], rax

    add rsp, 16
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

adjlist_has_edge:
    mov rax, [rdi + ADJL_HEADS]
    movsxd rcx, esi
    mov rax, [rax + rcx*8]

.has_loop:
    test rax, rax
    jz .has_not_found
    cmp dword [rax + NODE_DST], edx
    je .has_found
    mov rax, [rax + NODE_NEXT]
    jmp .has_loop

.has_found:
    mov eax, 1
    ret

.has_not_found:
    xor eax, eax
    ret

adjlist_out_degree:
    mov rax, [rdi + ADJL_HEADS]
    movsxd rcx, esi
    mov rax, [rax + rcx*8]
    xor ecx, ecx

.deg_loop:
    test rax, rax
    jz .deg_done
    inc ecx
    mov rax, [rax + NODE_NEXT]
    jmp .deg_loop

.deg_done:
    mov eax, ecx
    ret

adjlist_print:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 16

    mov rbx, rdi
    mov r14d, [rbx + ADJL_V]

    lea rdi, [rel fmt_info]
    mov esi, r14d
    xor eax, eax
    call printf

    xor r12d, r12d
.vert_loop:
    cmp r12d, r14d
    jge .print_done

    lea rdi, [rel fmt_vertex]
    mov esi, r12d
    xor eax, eax
    call printf

    mov rax, [rbx + ADJL_HEADS]
    movsxd rcx, r12d
    mov r13, [rax + rcx*8]

.edge_loop:
    test r13, r13
    jz .edge_done

    lea rdi, [rel fmt_edge]
    mov esi, [r13 + NODE_DST]
    mov edx, [r13 + NODE_WEIGHT]
    xor eax, eax
    call printf

    mov r13, [r13 + NODE_NEXT]
    jmp .edge_loop

.edge_done:
    lea rdi, [rel fmt_nl]
    xor eax, eax
    call printf

    inc r12d
    jmp .vert_loop

.print_done:
    add rsp, 16
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

adjlist_free:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 16

    mov rbx, rdi
    mov r14d, [rbx + ADJL_V]
    xor r12d, r12d

.free_vert:
    cmp r12d, r14d
    jge .free_heads

    mov rax, [rbx + ADJL_HEADS]
    movsxd rcx, r12d
    mov r13, [rax + rcx*8]

.free_chain:
    test r13, r13
    jz .free_next_vert

    mov rdi, r13
    mov r13, [r13 + NODE_NEXT]
    call free
    jmp .free_chain

.free_next_vert:
    inc r12d
    jmp .free_vert

.free_heads:
    mov rdi, [rbx + ADJL_HEADS]
    call free
    mov rdi, rbx
    call free

    add rsp, 16
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    mov edi, 5
    call adjlist_create
    mov rbx, rax

    mov rdi, rbx
    mov esi, 0
    mov edx, 1
    mov ecx, 10
    call adjlist_add_edge

    mov rdi, rbx
    mov esi, 0
    mov edx, 4
    mov ecx, 20
    call adjlist_add_edge

    mov rdi, rbx
    mov esi, 1
    mov edx, 2
    mov ecx, 30
    call adjlist_add_edge

    mov rdi, rbx
    mov esi, 1
    mov edx, 3
    mov ecx, 40
    call adjlist_add_edge

    mov rdi, rbx
    mov esi, 2
    mov edx, 3
    mov ecx, 50
    call adjlist_add_edge

    mov rdi, rbx
    mov esi, 3
    mov edx, 4
    mov ecx, 60
    call adjlist_add_edge

    mov rdi, rbx
    call adjlist_print

    mov rdi, rbx
    mov esi, 0
    mov edx, 1
    call adjlist_has_edge
    mov ecx, eax
    lea rdi, [rel fmt_has]
    mov esi, 0
    mov edx, 1
    xor eax, eax
    call printf

    mov rdi, rbx
    mov esi, 1
    mov edx, 0
    call adjlist_has_edge
    mov ecx, eax
    lea rdi, [rel fmt_has]
    mov esi, 1
    mov edx, 0
    xor eax, eax
    call printf

    mov rdi, rbx
    mov esi, 1
    call adjlist_out_degree
    mov edx, eax
    lea rdi, [rel fmt_outdeg]
    mov esi, 1
    xor eax, eax
    call printf

    lea rdi, [rel fmt_pass]
    xor eax, eax
    call printf

    mov rdi, rbx
    call adjlist_free

    xor eax, eax
    add rsp, 8
    pop rbx
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
