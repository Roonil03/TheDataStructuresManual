; BinaryTree.asm
BITS 64
default rel

extern malloc
extern scanf
extern printf

section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    scan_fmt db "%d", 0
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
    push rbp
    mov rbp, rsp
    sub rsp, 16
    xor r12, r12         ; root = NULL

.read_loop:
    lea rdi, [scan_fmt]
    lea rsi, [temp]
    xor eax, eax
    call scanf
    
    cmp eax, 1
    jne .print_tree
    
    mov esi, [temp]      ; Load input value
    test r12, r12
    jz .create_root
    
    mov rdi, r12
    call insert
    jmp .read_loop

.create_root:
    push rsi             ; Save input value
    mov edi, Node_size
    call malloc
    pop rsi              ; Restore input value
    
    mov qword [rax+Node.left], 0
    mov qword [rax+Node.right], 0
    mov dword [rax+Node.val], esi
    mov r12, rax         ; Store root pointer
    
    ; Print root value
    push rsi             ; Save value before printf
    lea rdi, [out_fmt]
    xor eax, eax
    call printf
    pop rsi              ; Restore (not needed but for consistency)
    jmp .read_loop

.print_tree:
    mov rdi, r12
    call inorder
    lea rdi, [nl]
    xor eax, eax
    call printf
    
    xor eax, eax
    leave
    ret

; void insert(Node* node, int value)
insert:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8           ; Align to 16 bytes (48 bytes pushed + 8 = 56, need 8 more)
    
    mov rbx, rdi         ; node pointer
    mov r13d, esi        ; value to insert
    
    ; Compare with current node value
    mov eax, [rbx+Node.val]
    cmp r13d, eax
    jle .left_branch

    ; Right subtree
    mov r12, [rbx+Node.right]
    test r12, r12
    jnz .recurse_right
    
    ; Create new right node
    mov edi, Node_size
    call malloc
    mov qword [rax+Node.left], 0
    mov qword [rax+Node.right], 0
    mov dword [rax+Node.val], r13d
    mov [rbx+Node.right], rax
    
    ; Print inserted value
    lea rdi, [out_fmt]
    mov esi, r13d
    xor eax, eax
    call printf
    jmp .done

.recurse_right:
    mov rdi, r12
    mov esi, r13d
    call insert
    jmp .done

.left_branch:
    mov r12, [rbx+Node.left]
    test r12, r12
    jnz .recurse_left
    
    ; Create new left node
    mov edi, Node_size
    call malloc
    mov qword [rax+Node.left], 0
    mov qword [rax+Node.right], 0
    mov dword [rax+Node.val], r13d
    mov [rbx+Node.left], rax
    
    ; Print inserted value
    lea rdi, [out_fmt]
    mov esi, r13d
    xor eax, eax
    call printf
    jmp .done

.recurse_left:
    mov rdi, r12
    mov esi, r13d
    call insert

.done:
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; void inorder(Node* node)
inorder:
    test rdi, rdi
    jz .end
    
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8           ; Align stack
    
    mov rbx, rdi         ; Save current node
    
    ; Traverse left subtree
    mov rdi, [rbx+Node.left]
    call inorder
    
    ; Print current node value
    lea rdi, [out_fmt]
    mov esi, [rbx+Node.val]
    xor eax, eax
    call printf
    
    ; Traverse right subtree  
    mov rdi, [rbx+Node.right]
    call inorder
    
    add rsp, 8
    pop rbx
    pop rbp

.end:
    ret
