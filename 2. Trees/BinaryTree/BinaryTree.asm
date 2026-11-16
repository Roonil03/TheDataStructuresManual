; Binary tree insertion fills both children before descending left.
extern exit, free

BITS 64
default rel

extern malloc
extern printf

section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    out_fmt  db "%d ", 0
    nl       db 10, 0

section .bss
    align 8
    struc Node,0
        .left:  resq 1
        .right: resq 1
        .val:   resd 1
    endstruc
    temp:   resd 1

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
    test r12, r12
    jz .create_root

    mov rdi, r12
    call insert
    jmp .read_loop

.create_root:
    sub rsp, 16
    mov [rsp], esi
    mov edi, Node_size
    call malloc
    test rax, rax
    jz allocation_error
    mov esi, [rsp]
    add rsp, 16
    mov qword [rax+Node.left], 0
    mov qword [rax+Node.right], 0
    mov [rax+Node.val], esi
    mov r12, rax
    jmp .read_loop

.print_tree:
    mov rdi, r12
    call inorder
    lea rdi, [nl]
    xor eax, eax
    call printf
    mov rdi, r12
    call preorder
    lea rdi, [nl]
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

insert:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov rbx, rdi
    mov r12d, esi
    cmp qword [rbx+Node.left], 0
    je .left
    cmp qword [rbx+Node.right], 0
    je .right
    mov rdi, [rbx+Node.left]
    call insert
    jmp .done
.left:
    mov edi, Node_size
    call malloc
    test rax, rax
    jz allocation_error
    mov [rbx+Node.left], rax
    jmp .initialize
.right:
    mov edi, Node_size
    call malloc
    test rax, rax
    jz allocation_error
    mov [rbx+Node.right], rax
.initialize:
    mov qword [rax+Node.left], 0
    mov qword [rax+Node.right], 0
    mov [rax+Node.val], r12d
.done:
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

    mov rdi, [rbx+Node.left]
    call inorder

    lea rdi, [out_fmt]
    mov esi, [rbx+Node.val]
    xor eax, eax
    call printf

    mov rdi, [rbx+Node.right]
    call inorder

    add rsp, 8
    pop rbx
    pop rbp

.end:
    ret

preorder:
    test rdi, rdi
    jz .done
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov rbx, rdi
    lea rdi, [out_fmt]
    mov esi, [rbx+Node.val]
    xor eax, eax
    call printf
    mov rdi, [rbx+Node.left]
    call preorder
    mov rdi, [rbx+Node.right]
    call preorder
    add rsp, 8
    pop rbx
    pop rbp
.done:
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
