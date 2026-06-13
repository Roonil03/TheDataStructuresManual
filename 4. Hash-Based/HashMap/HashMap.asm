section .data
    fmt_put:     db "Put %d -> %d", 10, 0
    fmt_get:     db "Get %d -> %d (found=%d)", 10, 0
    fmt_info:    db "HashMap: size=%d capacity=%d", 10, 0
    fmt_contains:db "Contains %d: %d", 10, 0
    fmt_pass:    db "All tests passed.", 10, 0

HM_CAP       equ 0
HM_SIZE      equ 4
HM_BUCKETS   equ 8
HM_STRUCT    equ 16

NODE_KEY     equ 0
NODE_VAL     equ 4
NODE_NEXT    equ 8
NODE_SIZE    equ 16

section .text
    global main, hashmap_create, hashmap_put, hashmap_get, hashmap_remove, hashmap_free
    extern malloc, calloc, free, printf

hashmap_create:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 16

    mov r12d, edi

    mov edi, HM_STRUCT
    call malloc
    mov rbx, rax
    mov dword [rbx + HM_CAP], r12d
    mov dword [rbx + HM_SIZE], 0

    movsxd rdi, r12d
    mov esi, 8
    call calloc
    mov [rbx + HM_BUCKETS], rax

    mov rax, rbx
    add rsp, 16
    pop r12
    pop rbx
    pop rbp
    ret

hashmap_hash:
    mov eax, edi
    mov ecx, esi
    xor edx, edx
    cdq
    idiv ecx
    mov eax, edx
    test eax, eax
    jns .hash_pos
    neg eax
.hash_pos:
    ret

hashmap_put:
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

    mov edi, r12d
    mov esi, [rbx + HM_CAP]
    call hashmap_hash
    mov r14d, eax

    mov rcx, [rbx + HM_BUCKETS]
    movsxd rax, r14d
    mov rdi, [rcx + rax*8]

.put_search:
    test rdi, rdi
    jz .put_new
    cmp dword [rdi + NODE_KEY], r12d
    jne .put_next
    mov dword [rdi + NODE_VAL], r13d
    jmp .put_done

.put_next:
    mov rdi, [rdi + NODE_NEXT]
    jmp .put_search

.put_new:
    mov edi, NODE_SIZE
    call malloc

    mov dword [rax + NODE_KEY], r12d
    mov dword [rax + NODE_VAL], r13d

    mov rcx, [rbx + HM_BUCKETS]
    movsxd rdx, r14d
    mov rdi, [rcx + rdx*8]
    mov [rax + NODE_NEXT], rdi
    mov [rcx + rdx*8], rax
    inc dword [rbx + HM_SIZE]

.put_done:
    add rsp, 16
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

hashmap_get:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8

    mov rbx, rdi
    mov r12d, esi
    mov r13, rdx

    mov edi, r12d
    mov esi, [rbx + HM_CAP]
    call hashmap_hash

    mov rcx, [rbx + HM_BUCKETS]
    movsxd rax, eax
    mov rdi, [rcx + rax*8]

.get_search:
    test rdi, rdi
    jz .get_not_found
    cmp dword [rdi + NODE_KEY], r12d
    jne .get_next
    mov eax, [rdi + NODE_VAL]
    mov [r13], eax
    mov eax, 1
    jmp .get_done

.get_next:
    mov rdi, [rdi + NODE_NEXT]
    jmp .get_search

.get_not_found:
    xor eax, eax

.get_done:
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

hashmap_contains:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 16

    mov rbx, rdi
    mov r12d, esi

    mov edi, r12d
    mov esi, [rbx + HM_CAP]
    call hashmap_hash

    mov rcx, [rbx + HM_BUCKETS]
    movsxd rax, eax
    mov rdi, [rcx + rax*8]

.cont_search:
    test rdi, rdi
    jz .cont_no
    cmp dword [rdi + NODE_KEY], r12d
    jne .cont_next
    mov eax, 1
    jmp .cont_done

.cont_next:
    mov rdi, [rdi + NODE_NEXT]
    jmp .cont_search

.cont_no:
    xor eax, eax

.cont_done:
    add rsp, 16
    pop r12
    pop rbx
    pop rbp
    ret

hashmap_free:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 16

    mov rbx, rdi
    mov r14d, [rbx + HM_CAP]
    xor r12d, r12d

.free_bucket:
    cmp r12d, r14d
    jge .free_struct

    mov rcx, [rbx + HM_BUCKETS]
    movsxd rax, r12d
    mov r13, [rcx + rax*8]

.free_chain:
    test r13, r13
    jz .free_next_bucket
    mov rdi, r13
    mov r13, [r13 + NODE_NEXT]
    call free
    jmp .free_chain

.free_next_bucket:
    inc r12d
    jmp .free_bucket

.free_struct:
    mov rdi, [rbx + HM_BUCKETS]
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
    sub rsp, 24

    mov edi, 8
    call hashmap_create
    mov rbx, rax

    mov rdi, rbx
    mov esi, 10
    mov edx, 100
    call hashmap_put

    mov rdi, rbx
    mov esi, 20
    mov edx, 200
    call hashmap_put

    mov rdi, rbx
    mov esi, 30
    mov edx, 300
    call hashmap_put

    mov rdi, rbx
    mov esi, 42
    mov edx, 420
    call hashmap_put

    lea rdi, [rel fmt_info]
    mov esi, [rbx + HM_SIZE]
    mov edx, [rbx + HM_CAP]
    xor eax, eax
    call printf

    mov rdi, rbx
    mov esi, 10
    call hashmap_contains
    mov edx, eax
    lea rdi, [rel fmt_contains]
    mov esi, 10
    xor eax, eax
    call printf

    mov rdi, rbx
    mov esi, 99
    call hashmap_contains
    mov edx, eax
    lea rdi, [rel fmt_contains]
    mov esi, 99
    xor eax, eax
    call printf

    lea rdx, [rbp - 20]
    mov rdi, rbx
    mov esi, 20
    call hashmap_get
    mov r8d, eax
    mov ecx, [rbp - 20]
    lea rdi, [rel fmt_get]
    mov esi, 20
    mov edx, ecx
    mov ecx, r8d
    xor eax, eax
    call printf

    mov rdi, rbx
    mov esi, 20
    mov edx, 999
    call hashmap_put

    lea rdx, [rbp - 20]
    mov rdi, rbx
    mov esi, 20
    call hashmap_get
    mov r8d, eax
    mov ecx, [rbp - 20]
    lea rdi, [rel fmt_get]
    mov esi, 20
    mov edx, ecx
    mov ecx, r8d
    xor eax, eax
    call printf

    lea rdi, [rel fmt_pass]
    xor eax, eax
    call printf

    mov rdi, rbx
    call hashmap_free

    xor eax, eax
    add rsp, 24
    pop rbx
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
