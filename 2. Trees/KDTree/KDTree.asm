; Alternating-axis point insertion with exhaustive nearest search.
BITS 64
default rel

section .data
    fmt_point   db "(%d,%d) ", 0
    fmt_nl      db 10, 0
    fmt_nearest db "Nearest to (%d,%d): (%d,%d)", 10, 0
    msg_tree    db "Tree: ", 0

section .bss
    n           resd 1
    tree_nodes  resb 3200
    node_count  resd 1
    query_x     resd 1
    query_y     resd 1
    best_x      resd 1
    best_y      resd 1
    best_dist   resq 1
    best_high   resq 1

section .text
    extern printf
    global main

main:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    lea rdi, [rel n]
    call tree_read_int
    cmp eax, 1
    jne input_error
    cmp dword [n], 1
    jl input_error
    cmp dword [n], 100
    jg input_error

    mov     dword [rel node_count], 0
    xor     r14, r14
    xor     r12d, r12d

input_loop:
    cmp     r12d, dword [rel n]
    jge     query_input

    lea rdi, [rbp-4]
    call tree_read_int
    cmp eax, 1
    jne input_error

    lea rdi, [rbp-8]
    call tree_read_int
    cmp eax, 1
    jne input_error

    mov     edi, [rbp-4]
    mov     esi, [rbp-8]
    mov     rdx, r14
    xor     ecx, ecx
    call    insert_node
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

    lea rdi, [rel query_x]
    call tree_read_int
    cmp eax, 1
    jne input_error

    lea rdi, [rel query_y]
    call tree_read_int
    cmp eax, 1
    jne input_error

    mov qword [best_dist], -1
    mov qword [best_high], -1
    mov     rdi, r14
    call    find_nearest

    lea     rdi, [rel fmt_nearest]
    mov     esi, [rel query_x]
    mov     edx, [rel query_y]
    mov     ecx, [rel best_x]
    mov     r8d, [rel best_y]
    xor     eax, eax
    call    printf

    xor     eax, eax
    leave
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

input_error:
    mov eax, 1
    leave
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

insert_node:
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

    mov     eax, dword [rel node_count]
    inc     dword [rel node_count]
    mov     ebx, 32
    mul     ebx
    lea     rax, [tree_nodes + rax]

    mov     [rax], r12d
    mov     [rax + 4], r13d
    mov     qword [rax + 8], 0
    mov     qword [rax + 16], 0
    mov     [rax + 24], ecx
    jmp     insert_end

has_node:
    mov     ebx, ecx
    and     ebx, 1

    test    ebx, ebx
    jnz     comp_y

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

print_tree:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub rsp, 8

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
    add rsp, 8
    pop     rbx
    pop     rbp
    ret

find_nearest:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12

    test    rdi, rdi
    jz      find_end

    mov     rbx, rdi

    movsxd rax, dword [query_x]
    movsxd rcx, dword [rbx]
    sub rax, rcx
    imul rax, rax
    mov r8, rax
    movsxd rax, dword [query_y]
    movsxd rcx, dword [rbx + 4]
    sub rax, rcx
    imul rax, rax
    xor edx, edx
    add rax, r8
    adc rdx, 0
    cmp rdx, [best_high]
    ja no_update
    jb update_best
    cmp rax, [best_dist]
    jae no_update
update_best:
    mov [best_dist], rax
    mov [best_high], rdx
    mov     ecx, [rbx]
    mov     [rel best_x], ecx
    mov     ecx, [rbx + 4]
    mov     [rel best_y], ecx

no_update:

    mov     rdi, [rbx + 8]
    call    find_nearest

    mov     rdi, [rbx + 16]
    call    find_nearest

find_end:
    pop     r12
    pop     rbx
    pop     rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits

; Resolve the shared parser relative to this source, independent of the build directory.
%strlen tree_input_pos __?FILE?__
%assign tree_input_length tree_input_pos
%define tree_input_dir ""
%rep tree_input_length
    %substr tree_input_char __?FILE?__ tree_input_pos
    %ifidn tree_input_char, "/"
        %substr tree_input_dir __?FILE?__ 1, tree_input_pos
        %exitrep
    %endif
    %assign tree_input_pos tree_input_pos - 1
%endrep
%strcat tree_input_path tree_input_dir, "../nasm_input.inc"
%include tree_input_path
