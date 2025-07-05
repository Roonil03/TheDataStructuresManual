; rbtree.asm
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc
extern scanf
extern printf

section .data
    fmt_scan  db "%d", 0
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
    push rbp
    mov rbp, rsp
    sub rsp, 16
    xor r12, r12                  ; root = NULL

.read_loop:
    lea rdi, [fmt_scan]
    lea rsi, [temp]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne .print_tree
    mov esi, [temp]
    mov rdi, r12
    call insert
    mov r12, rax                  ; update root
    jmp .read_loop

.print_tree:
    mov rdi, r12
    call inorder
    lea rdi, [newline]
    xor eax, eax
    call printf
    xor eax, eax
    leave
    ret

insert:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8

    mov r12, rdi                  ; original root
    mov r13d, esi                 ; key to insert

    ; allocate new node
    mov edi, Node_size
    call malloc
    mov r14, rax                  ; save new node
    mov dword [r14 + Node.key], r13d
    mov byte [r14 + Node.color], 1
    mov qword [r14 + Node.left], 0
    mov qword [r14 + Node.right], 0
    mov qword [r14 + Node.parent], 0

    test r12, r12
    jz .set_root

    ; find insertion point
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
    mov byte [r14 + Node.color], 0
    mov rax, r12                  ; return original root
    jmp .done

.insert_left:
    mov [rbx + Node.left], r14
    mov [r14 + Node.parent], rbx
    mov byte [r14 + Node.color], 0
    mov rax, r12                  ; return original root
    jmp .done

.set_root:
    mov byte [r14 + Node.color], 0
    mov rax, r14                  ; return new node as root

.done:
    add rsp, 8
    pop r14
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
    
    ; left subtree
    mov rdi, [rbx + Node.left]
    call inorder
    
    ; print current node
    lea rdi, [fmt_print]
    mov esi, [rbx + Node.key]
    xor eax, eax
    call printf
    
    ; right subtree
    mov rdi, [rbx + Node.right]
    call inorder
    
    add rsp, 8
    pop rbx
    pop rbp

.end:
    ret
