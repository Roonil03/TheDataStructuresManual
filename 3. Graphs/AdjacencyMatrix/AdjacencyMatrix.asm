section .data
    fmt_info:    db "Adjacency Matrix (%d vertices):", 10, 0
    fmt_val:     db "%3d ", 0
    fmt_nl:      db 10, 0
    fmt_has:     db "Edge %d->%d exists: %d", 10, 0
    fmt_weight:  db "Weight %d->%d: %d", 10, 0

ADJM_V       equ 0
ADJM_MATRIX  equ 8
ADJM_SIZE    equ 16

section .text
    global main, adjmatrix_create, adjmatrix_add_edge, adjmatrix_has_edge, adjmatrix_get_weight, adjmatrix_remove_edge, adjmatrix_print, adjmatrix_free
    extern malloc, calloc, free, printf

adjmatrix_create:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 16

    test edi, edi
    js .invalid
    mov r12d, edi

    mov edi, ADJM_SIZE
    call malloc
    test rax, rax
    jz .done
    mov rbx, rax

    mov dword [rbx + ADJM_V], r12d

    mov edi, r12d
    imul rdi, rdi
    mov esi, 4
    call calloc
    test rax, rax
    jnz .storage_ready
    test r12d, r12d
    jz .storage_ready
    mov rdi, rbx
    call free
.invalid:
    xor eax, eax
    jmp .done
.storage_ready:
    mov [rbx + ADJM_MATRIX], rax

    mov rax, rbx
.done:
    add rsp, 16
    pop r12
    pop rbx
    pop rbp
    ret

adjmatrix_cell:
    cmp esi, [rdi + ADJM_V]
    jae .invalid
    cmp edx, [rdi + ADJM_V]
    jae .invalid
    mov eax, [rdi + ADJM_V]
    mov esi, esi
    imul rax, rsi
    mov edx, edx
    add rax, rdx
    mov rdx, [rdi + ADJM_MATRIX]
    lea rax, [rdx + rax*4]
    ret
.invalid:
    xor eax, eax
    ret

adjmatrix_add_edge:
    sub rsp, 8
    call adjmatrix_cell
    add rsp, 8
    test rax, rax
    jz .done
    mov [rax], ecx
.done:
    ret

adjmatrix_remove_edge:
    xor ecx, ecx
    jmp adjmatrix_add_edge

adjmatrix_has_edge:
    sub rsp, 8
    call adjmatrix_get_weight
    add rsp, 8
    test eax, eax
    setnz al
    movzx eax, al
    ret

adjmatrix_get_weight:
    sub rsp, 8
    call adjmatrix_cell
    add rsp, 8
    test rax, rax
    jz .done
    mov eax, [rax]
.done:
    ret

adjmatrix_print:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov rbx, rdi
    mov r15d, [rbx + ADJM_V]
    mov r14, [rbx + ADJM_MATRIX]

    lea rdi, [rel fmt_info]
    mov esi, r15d
    xor eax, eax
    call printf

    xor r12d, r12d
.row_loop:
    cmp r12d, r15d
    jge .done

    xor r13d, r13d
.col_loop:
    cmp r13d, r15d
    jge .row_end

    mov eax, r12d
    imul rax, r15
    add rax, r13
    mov esi, [r14 + rax*4]
    lea rdi, [rel fmt_val]
    xor eax, eax
    call printf

    inc r13d
    jmp .col_loop

.row_end:
    lea rdi, [rel fmt_nl]
    xor eax, eax
    call printf
    inc r12d
    jmp .row_loop

.done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

adjmatrix_free:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    mov rbx, rdi
    mov rdi, [rbx + ADJM_MATRIX]
    call free
    mov rdi, rbx
    call free

    add rsp, 8
    pop rbx
    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    mov edi, 5
    call adjmatrix_create
    test rax, rax
    jz .failure
    mov rbx, rax

    mov rdi, rbx
    mov esi, 0
    mov edx, 1
    mov ecx, 10
    call adjmatrix_add_edge

    mov rdi, rbx
    mov esi, 0
    mov edx, 4
    mov ecx, 20
    call adjmatrix_add_edge

    mov rdi, rbx
    mov esi, 1
    mov edx, 2
    mov ecx, 30
    call adjmatrix_add_edge

    mov rdi, rbx
    mov esi, 1
    mov edx, 3
    mov ecx, 40
    call adjmatrix_add_edge

    mov rdi, rbx
    mov esi, 1
    mov edx, 4
    mov ecx, 50
    call adjmatrix_add_edge

    mov rdi, rbx
    mov esi, 2
    mov edx, 3
    mov ecx, 60
    call adjmatrix_add_edge

    mov rdi, rbx
    mov esi, 3
    mov edx, 4
    mov ecx, 70
    call adjmatrix_add_edge

    mov rdi, rbx
    call adjmatrix_print

    mov rdi, rbx
    mov esi, 0
    mov edx, 1
    call adjmatrix_has_edge
    mov ecx, eax
    lea rdi, [rel fmt_has]
    mov esi, 0
    mov edx, 1
    xor eax, eax
    call printf

    mov rdi, rbx
    mov esi, 1
    mov edx, 0
    call adjmatrix_has_edge
    mov ecx, eax
    lea rdi, [rel fmt_has]
    mov esi, 1
    mov edx, 0
    xor eax, eax
    call printf

    mov rdi, rbx
    mov esi, 1
    mov edx, 2
    call adjmatrix_get_weight
    mov ecx, eax
    lea rdi, [rel fmt_weight]
    mov esi, 1
    mov edx, 2
    xor eax, eax
    call printf

    mov rdi, rbx
    mov esi, 0
    mov edx, 1
    call adjmatrix_remove_edge

    mov rdi, rbx
    mov esi, 0
    mov edx, 1
    call adjmatrix_has_edge
    mov ecx, eax
    lea rdi, [rel fmt_has]
    mov esi, 0
    mov edx, 1
    xor eax, eax
    call printf

    mov rdi, rbx
    call adjmatrix_free

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
