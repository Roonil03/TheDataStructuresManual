; avltree.asm
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc
extern scanf
extern printf

section .data
    scan_fmt   db "%d", 0
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
    push rbp
    mov rbp, rsp
    sub rsp, 16
    xor r12, r12

.read_loop:
    lea rdi, [scan_fmt]
    lea rsi, [temp]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne .print_tree
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
    xor eax, eax
    leave
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
    
    mov r8, rdi                    ; y
    mov r9, [r8 + Node.left]       ; x
    mov r10, [r9 + Node.right]     ; T2
    
    mov [r9 + Node.right], r8      ; x->right = y
    mov [r8 + Node.left], r10      ; y->left = T2
    
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
    
    mov r8, rdi                    ; x
    mov r9, [r8 + Node.right]      ; y
    mov r10, [r9 + Node.left]      ; T2
    
    mov [r9 + Node.left], r8       ; y->left = x
    mov [r8 + Node.right], r10     ; x->right = T2
    
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
    
    mov rbx, rdi                   ; node
    mov r12d, esi                  ; key
    
    test rbx, rbx
    jnz .not_null
    
    ; Create new node
    mov edi, Node_size
    call malloc
    mov [rax + Node.key], r12d
    mov dword [rax + Node.height], 1
    mov qword [rax + Node.left], 0
    mov qword [rax + Node.right], 0
    jmp .done

.not_null:
    cmp r12d, [rbx + Node.key]
    je .done_with_node             ; duplicate key, return original
    jl .go_left
    
    ; Insert right
    mov rdi, [rbx + Node.right]
    mov esi, r12d
    call insert
    mov [rbx + Node.right], rax
    jmp .balance

.go_left:
    ; Insert left
    mov rdi, [rbx + Node.left]
    mov esi, r12d
    call insert
    mov [rbx + Node.left], rax

.balance:
    ; Update height
    mov rdi, rbx
    call update_height
    
    ; Get balance factor
    mov rdi, rbx
    call get_balance
    mov r13d, eax                  ; balance factor
    
    ; Check left heavy (balance > 1)
    cmp r13d, 1
    jg .left_heavy
    
    ; Check right heavy (balance < -1)
    cmp r13d, -1
    jl .right_heavy
    
    ; Tree is balanced
    jmp .done_with_node

.left_heavy:
    ; Check left child exists
    mov rdi, [rbx + Node.left]
    test rdi, rdi
    jz .done_with_node
    
    mov eax, [rdi + Node.key]
    cmp r12d, eax
    jl .left_left
    
    ; Left-Right case
    mov rdi, [rbx + Node.left]
    call left_rotate
    mov [rbx + Node.left], rax
    mov rdi, rbx
    call right_rotate
    mov rbx, rax
    jmp .done_with_node

.left_left:
    ; Left-Left case
    mov rdi, rbx
    call right_rotate
    mov rbx, rax
    jmp .done_with_node

.right_heavy:
    ; Check right child exists
    mov rdi, [rbx + Node.right]
    test rdi, rdi
    jz .done_with_node
    
    mov eax, [rdi + Node.key]
    cmp r12d, eax
    jg .right_right
    
    ; Right-Left case
    mov rdi, [rbx + Node.right]
    call right_rotate
    mov [rbx + Node.right], rax
    mov rdi, rbx
    call left_rotate
    mov rbx, rax
    jmp .done_with_node

.right_right:
    ; Right-Right case
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
    
    ; Left subtree
    mov rdi, [rbx + Node.left]
    call inorder
    
    ; Print current
    lea rdi, [print_fmt]
    mov esi, [rbx + Node.key]
    xor eax, eax
    call printf
    
    ; Right subtree
    mov rdi, [rbx + Node.right]
    call inorder
    
    add rsp, 8
    pop rbx
    pop rbp

.end:
    ret
