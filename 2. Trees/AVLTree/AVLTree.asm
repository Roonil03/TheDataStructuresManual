; AVL insertion with stored subtree heights and rotations.
extern exit, free

BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc
extern printf

section .data
    print_fmt  db "%d ", 0
    newline    db 10, 0

section .bss
    align 8
    struc Node
        .key:     resd 1
        .height:  resd 1
        .left:    resq 1
        .right:   resq 1
    endstruc
    temp       resd 1

section .text
    global main

main:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    push rbp
    mov rbp, rsp
    sub rsp, 16
    xor r12, r12
    mov dword [rbp-8], 0

.read_loop:
    lea rdi, [temp]
    call tree_read_int
    cmp eax, -1
    je .print_tree
    cmp eax, 1
    jne .invalid_input
    mov esi, [temp]
    mov rdi, r12
    call insert
    mov r12, rax
    jmp .read_loop

.print_tree:
    mov rdi, r12
    call inorder
    lea rdi, [newline]
    xor eax, eax
    call printf
    jmp .cleanup
.invalid_input:
    mov dword [rbp-8], 1
.cleanup:
    mov rdi, r12
    call free_tree
    mov eax, [rbp-8]
    leave
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
height:
    test rdi, rdi
    jz .null
    mov eax, [rdi + Node.height]
    ret
.null:
    xor eax, eax
    ret

max_height:
    cmp edi, esi
    cmovl edi, esi
    mov eax, edi
    ret

update_height:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    mov rbx, rdi
    mov rdi, [rbx + Node.left]
    call height
    mov ecx, eax

    mov rdi, [rbx + Node.right]
    call height

    mov edi, ecx
    mov esi, eax
    call max_height
    inc eax
    mov [rbx + Node.height], eax

    add rsp, 8
    pop rbx
    pop rbp
    ret

get_balance:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    mov rbx, rdi
    mov rdi, [rbx + Node.left]
    call height
    mov ecx, eax

    mov rdi, [rbx + Node.right]
    call height

    sub ecx, eax
    mov eax, ecx

    add rsp, 8
    pop rbx
    pop rbp
    ret

right_rotate:
    push rbp
    mov rbp, rsp

    mov r8, rdi
    mov r9, [r8 + Node.left]
    mov r10, [r9 + Node.right]

    mov [r9 + Node.right], r8
    mov [r8 + Node.left], r10

    mov rdi, r8
    call update_height
    mov rdi, r9
    call update_height

    mov rax, r9
    pop rbp
    ret

left_rotate:
    push rbp
    mov rbp, rsp

    mov r8, rdi
    mov r9, [r8 + Node.right]
    mov r10, [r9 + Node.left]

    mov [r9 + Node.left], r8
    mov [r8 + Node.right], r10

    mov rdi, r8
    call update_height
    mov rdi, r9
    call update_height

    mov rax, r9
    pop rbp
    ret

insert:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8

    mov rbx, rdi
    mov r12d, esi

    test rbx, rbx
    jnz .not_null

    mov edi, Node_size
    call malloc
    test rax, rax
    jz allocation_error
    mov [rax + Node.key], r12d
    mov dword [rax + Node.height], 1
    mov qword [rax + Node.left], 0
    mov qword [rax + Node.right], 0
    jmp .done

.not_null:
    cmp r12d, [rbx + Node.key]
    je .done_with_node
    jl .go_left

    mov rdi, [rbx + Node.right]
    mov esi, r12d
    call insert
    mov [rbx + Node.right], rax
    jmp .balance

.go_left:

    mov rdi, [rbx + Node.left]
    mov esi, r12d
    call insert
    mov [rbx + Node.left], rax

.balance:

    mov rdi, rbx
    call update_height

    mov rdi, rbx
    call get_balance
    mov r13d, eax

    cmp r13d, 1
    jg .left_heavy

    cmp r13d, -1
    jl .right_heavy

    jmp .done_with_node

.left_heavy:

    mov rdi, [rbx + Node.left]
    test rdi, rdi
    jz .done_with_node

    mov eax, [rdi + Node.key]
    cmp r12d, eax
    jl .left_left

    mov rdi, [rbx + Node.left]
    call left_rotate
    mov [rbx + Node.left], rax
    mov rdi, rbx
    call right_rotate
    mov rbx, rax
    jmp .done_with_node

.left_left:

    mov rdi, rbx
    call right_rotate
    mov rbx, rax
    jmp .done_with_node

.right_heavy:

    mov rdi, [rbx + Node.right]
    test rdi, rdi
    jz .done_with_node

    mov eax, [rdi + Node.key]
    cmp r12d, eax
    jg .right_right

    mov rdi, [rbx + Node.right]
    call right_rotate
    mov [rbx + Node.right], rax
    mov rdi, rbx
    call left_rotate
    mov rbx, rax
    jmp .done_with_node

.right_right:

    mov rdi, rbx
    call left_rotate
    mov rbx, rax

.done_with_node:
    mov rax, rbx

.done:
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

inorder:
    test rdi, rdi
    jz .end

    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    mov rbx, rdi

    mov rdi, [rbx + Node.left]
    call inorder

    lea rdi, [print_fmt]
    mov esi, [rbx + Node.key]
    xor eax, eax
    call printf

    mov rdi, [rbx + Node.right]
    call inorder

    add rsp, 8
    pop rbx
    pop rbp

.end:
    ret

section .text
allocation_error:
    mov edi, 1
    call exit
    ud2


free_tree:
    test rdi, rdi
    jz .done
    push rbx
    mov rbx, rdi
    mov rdi, [rbx + Node.left]
    call free_tree
    mov rdi, [rbx + Node.right]
    call free_tree
    mov rdi, rbx
    pop rbx
    jmp free
.done:
    ret

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
