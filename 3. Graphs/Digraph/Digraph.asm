section .data
    fmt_info:    db "Digraph: %d vertices, %d edges", 10, 0
    fmt_edge:    db "  %d -> %d (w=%d)", 10, 0
    fmt_has:     db "Edge %d->%d exists: %d", 10, 0
    fmt_outdeg:  db "Out-degree of %d: %d", 10, 0

DIGRAPH_V      equ 0
DIGRAPH_E      equ 4
DIGRAPH_CAP    equ 8
DIGRAPH_EDGES  equ 16
DIGRAPH_SIZE   equ 24

EDGE_SRC       equ 0
EDGE_DST       equ 4
EDGE_WEIGHT    equ 8
EDGE_SIZE      equ 12

section .text
    global main, digraph_create, digraph_add_edge, digraph_has_edge, digraph_out_degree, digraph_free
    extern malloc, realloc, free, printf

digraph_create:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8

    test edi, edi
    js .invalid
    test esi, esi
    js .invalid
    mov r12d, edi
    mov r13d, esi

    mov edi, DIGRAPH_SIZE
    call malloc
    test rax, rax
    jz .done
    mov rbx, rax

    mov dword [rbx + DIGRAPH_V], r12d
    mov dword [rbx + DIGRAPH_E], 0
    mov dword [rbx + DIGRAPH_CAP], r13d

    imul rdi, r13, EDGE_SIZE
    call malloc
    test rax, rax
    jnz .storage_ready
    test r13d, r13d
    jz .storage_ready
    mov rdi, rbx
    call free
.invalid:
    xor eax, eax
    jmp .done
.storage_ready:
    mov [rbx + DIGRAPH_EDGES], rax

    mov rax, rbx
.done:
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

digraph_add_edge:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    cmp esi, [rdi + DIGRAPH_V]
    jae .done
    cmp edx, [rdi + DIGRAPH_V]
    jae .done
    mov rbx, rdi
    mov r12d, esi
    mov r13d, edx
    mov r14d, ecx

    mov eax, [rbx + DIGRAPH_E]
    cmp eax, [rbx + DIGRAPH_CAP]
    jl .add_no_grow

    mov eax, [rbx + DIGRAPH_CAP]
    test eax, eax
    jnz .cap_not_zero
    mov eax, 1
    jmp .cap_done
.cap_not_zero:
    cmp eax, 0x3fffffff
    ja .done
    shl eax, 1
.cap_done:
    mov r15d, eax
    imul rsi, r15, EDGE_SIZE
    mov rdi, [rbx + DIGRAPH_EDGES]
    call realloc
    test rax, rax
    jz .done
    mov [rbx + DIGRAPH_CAP], r15d
    mov [rbx + DIGRAPH_EDGES], rax

.add_no_grow:
    mov eax, [rbx + DIGRAPH_E]
    imul rcx, rax, EDGE_SIZE
    mov rdi, [rbx + DIGRAPH_EDGES]
    add rdi, rcx

    mov dword [rdi + EDGE_SRC], r12d
    mov dword [rdi + EDGE_DST], r13d
    mov dword [rdi + EDGE_WEIGHT], r14d
    inc dword [rbx + DIGRAPH_E]

.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

digraph_has_edge:
    push rbp
    mov rbp, rsp

    mov rcx, [rdi + DIGRAPH_EDGES]
    mov r8d, [rdi + DIGRAPH_E]
    xor eax, eax

.has_loop:
    cmp eax, r8d
    jge .has_not_found

    mov r9d, eax
    imul r9, EDGE_SIZE

    cmp dword [rcx + r9 + EDGE_SRC], esi
    jne .has_next
    cmp dword [rcx + r9 + EDGE_DST], edx
    jne .has_next

    mov eax, 1
    pop rbp
    ret

.has_next:
    inc eax
    jmp .has_loop

.has_not_found:
    xor eax, eax
    pop rbp
    ret

digraph_out_degree:
    push rbp
    mov rbp, rsp

    mov rcx, [rdi + DIGRAPH_EDGES]
    mov r8d, [rdi + DIGRAPH_E]
    xor eax, eax
    xor r9d, r9d

.outdeg_loop:
    cmp r9d, r8d
    jge .outdeg_done

    mov r10d, r9d
    imul r10, EDGE_SIZE

    cmp dword [rcx + r10 + EDGE_SRC], esi
    jne .outdeg_next
    inc eax

.outdeg_next:
    inc r9d
    jmp .outdeg_loop

.outdeg_done:
    pop rbp
    ret

digraph_free:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    mov rbx, rdi
    mov rdi, [rbx + DIGRAPH_EDGES]
    call free
    mov rdi, rbx
    call free

    add rsp, 8
    pop rbx
    pop rbp
    ret

digraph_print:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8

    mov rbx, rdi
    lea rdi, [rel fmt_info]
    mov esi, [rbx + DIGRAPH_V]
    mov edx, [rbx + DIGRAPH_E]
    xor eax, eax
    call printf

    xor r12d, r12d
    mov r13d, [rbx + DIGRAPH_E]

.print_loop:
    cmp r12d, r13d
    jge .print_done

    mov eax, r12d
    imul rcx, rax, EDGE_SIZE
    mov rdi, [rbx + DIGRAPH_EDGES]
    add rdi, rcx

    mov ecx, [rdi + EDGE_WEIGHT]
    mov edx, [rdi + EDGE_DST]
    mov esi, [rdi + EDGE_SRC]
    lea rdi, [rel fmt_edge]
    xor eax, eax
    call printf

    inc r12d
    jmp .print_loop

.print_done:
    add rsp, 8
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

    mov edi, 6
    mov esi, 4
    call digraph_create
    test rax, rax
    jz .failure
    mov rbx, rax

    mov rdi, rbx
    mov esi, 5
    mov edx, 2
    mov ecx, 1
    call digraph_add_edge

    mov rdi, rbx
    mov esi, 5
    mov edx, 0
    mov ecx, 1
    call digraph_add_edge

    mov rdi, rbx
    mov esi, 4
    mov edx, 0
    mov ecx, 1
    call digraph_add_edge

    mov rdi, rbx
    mov esi, 4
    mov edx, 1
    mov ecx, 1
    call digraph_add_edge

    mov rdi, rbx
    mov esi, 2
    mov edx, 3
    mov ecx, 1
    call digraph_add_edge

    mov rdi, rbx
    mov esi, 3
    mov edx, 1
    mov ecx, 1
    call digraph_add_edge

    mov rdi, rbx
    call digraph_print

    mov rdi, rbx
    mov esi, 5
    mov edx, 2
    call digraph_has_edge
    mov ecx, eax
    lea rdi, [rel fmt_has]
    mov esi, 5
    mov edx, 2
    xor eax, eax
    call printf

    mov rdi, rbx
    mov esi, 2
    mov edx, 5
    call digraph_has_edge
    mov ecx, eax
    lea rdi, [rel fmt_has]
    mov esi, 2
    mov edx, 5
    xor eax, eax
    call printf

    mov rdi, rbx
    mov esi, 5
    call digraph_out_degree
    mov edx, eax
    lea rdi, [rel fmt_outdeg]
    mov esi, 5
    xor eax, eax
    call printf

    mov rdi, rbx
    call digraph_free

    xor eax, eax
    jmp .done
.failure:
    mov eax, 1
.done:
    add rsp, 8
    pop rbx
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
