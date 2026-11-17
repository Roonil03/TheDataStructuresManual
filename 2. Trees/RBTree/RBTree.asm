; Red = 1, black = 0; null child pointers are black leaves.
extern exit

BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern free
extern malloc
extern printf

section .data
    fmt_print db "%d ", 0
    newline   db 10, 0

section .bss
    align 8
    struc Node
        .key:    resd 1
        .color:  resb 1
        .pad:    resb 3
        .left:   resq 1
        .right:  resq 1
        .parent: resq 1
    endstruc
    temp      resd 1

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
    call destroy
    mov eax, [rbp-8]
    leave
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
insert:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    mov r12, rdi
    mov r13d, esi

    mov edi, Node_size
    call malloc
    test rax, rax
    jz allocation_error
    mov r14, rax
    mov dword [r14 + Node.key], r13d
    mov byte [r14 + Node.color], 1
    mov qword [r14 + Node.left], 0
    mov qword [r14 + Node.right], 0
    mov qword [r14 + Node.parent], 0

    test r12, r12
    jz .set_root

    mov rbx, r12
.find_parent:
    cmp r13d, [rbx + Node.key]
    jl .check_left
    mov rax, [rbx + Node.right]
    test rax, rax
    jz .insert_right
    mov rbx, rax
    jmp .find_parent

.check_left:
    mov rax, [rbx + Node.left]
    test rax, rax
    jz .insert_left
    mov rbx, rax
    jmp .find_parent

.insert_right:
    mov [rbx + Node.right], r14
    mov [r14 + Node.parent], rbx
    jmp .fixup

.insert_left:
    mov [rbx + Node.left], r14
    mov [r14 + Node.parent], rbx
    jmp .fixup

.set_root:
    mov r12, r14
.fixup:
    mov rbx, [r14 + Node.parent]
    test rbx, rbx
    jz .black_root
    cmp byte [rbx + Node.color], 0
    je .black_root
    mov r13, [rbx + Node.parent]
    cmp [r13 + Node.left], rbx
    jne .parent_right
    mov rax, [r13 + Node.right]
    test rax, rax
    jz .left_rotate_case
    cmp byte [rax + Node.color], 1
    jne .left_rotate_case
.recolor:
    mov byte [rbx + Node.color], 0
    mov byte [rax + Node.color], 0
    mov byte [r13 + Node.color], 1
    mov r14, r13
    jmp .fixup
.left_rotate_case:
    cmp [rbx + Node.right], r14
    jne .left_line
    mov r14, rbx
    mov rdi, r12
    mov rsi, r14
    call rotate_left
    mov r12, rax
    mov rbx, [r14 + Node.parent]
    mov r13, [rbx + Node.parent]
.left_line:
    mov byte [rbx + Node.color], 0
    mov byte [r13 + Node.color], 1
    mov rdi, r12
    mov rsi, r13
    call rotate_right
    mov r12, rax
    jmp .fixup
.parent_right:
    mov rax, [r13 + Node.left]
    test rax, rax
    jz .right_rotate_case
    cmp byte [rax + Node.color], 1
    je .recolor
.right_rotate_case:
    cmp [rbx + Node.left], r14
    jne .right_line
    mov r14, rbx
    mov rdi, r12
    mov rsi, r14
    call rotate_right
    mov r12, rax
    mov rbx, [r14 + Node.parent]
    mov r13, [rbx + Node.parent]
.right_line:
    mov byte [rbx + Node.color], 0
    mov byte [r13 + Node.color], 1
    mov rdi, r12
    mov rsi, r13
    call rotate_left
    mov r12, rax
    jmp .fixup
.black_root:
    mov byte [r12 + Node.color], 0
    mov rax, r12
.done:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; RDI is the root, RSI the pivot; return the possibly changed root.
rotate_left:
    mov rax, rdi
    mov rdx, [rsi + Node.right]
    mov rcx, [rdx + Node.left]
    mov [rsi + Node.right], rcx
    test rcx, rcx
    jz .parent
    mov [rcx + Node.parent], rsi
.parent:
    mov r8, [rsi + Node.parent]
    mov [rdx + Node.parent], r8
    test r8, r8
    jnz .attach
    mov rax, rdx
    jmp .finish
.attach:
    cmp [r8 + Node.left], rsi
    jne .right
    mov [r8 + Node.left], rdx
    jmp .finish
.right:
    mov [r8 + Node.right], rdx
.finish:
    mov [rdx + Node.left], rsi
    mov [rsi + Node.parent], rdx
    ret

rotate_right:
    mov rax, rdi
    mov rdx, [rsi + Node.left]
    mov rcx, [rdx + Node.right]
    mov [rsi + Node.left], rcx
    test rcx, rcx
    jz .parent
    mov [rcx + Node.parent], rsi
.parent:
    mov r8, [rsi + Node.parent]
    mov [rdx + Node.parent], r8
    test r8, r8
    jnz .attach
    mov rax, rdx
    jmp .finish
.attach:
    cmp [r8 + Node.right], rsi
    jne .left
    mov [r8 + Node.right], rdx
    jmp .finish
.left:
    mov [r8 + Node.left], rdx
.finish:
    mov [rdx + Node.right], rsi
    mov [rsi + Node.parent], rdx
    ret

destroy:
    test rdi, rdi
    jz .return
    push rbx
    mov rbx, rdi
    mov rdi, [rbx + Node.left]
    call destroy
    mov rdi, [rbx + Node.right]
    call destroy
    mov rdi, rbx
    call free
    pop rbx
.return:
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

    lea rdi, [fmt_print]
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
