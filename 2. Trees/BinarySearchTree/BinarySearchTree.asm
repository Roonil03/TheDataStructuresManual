;BinarySearch Tree
BITS 64
default rel
extern malloc, scanf, printf

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
    temp: resd 1

section .text
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    xor r12, r12

.input_loop:
    lea rdi, [scan_fmt]
    lea rsi, [temp]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne .show_tree
    
    mov esi, [temp]
    test r12, r12
    jz .new_root
    
    mov rdi, r12
    call insert
    jmp .input_loop

.new_root:
    push rsi
    mov edi, Node_size
    call malloc
    pop rsi
    mov qword [rax+Node.left], 0
    mov qword [rax+Node.right], 0
    mov dword [rax+Node.val], esi
    mov r12, rax
    jmp .input_loop

.show_tree:
    mov rdi, r12
    call inorder
    lea rdi, [nl]
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
    sub rsp, 8
    
    mov rbx, rdi
    mov r13d, esi
    
    mov eax, [rbx+Node.val]
    cmp r13d, eax
    jg .go_right
    
    mov r12, [rbx+Node.left]
    test r12, r12
    jnz .left_recurse
    
    mov edi, Node_size
    call malloc
    mov qword [rax+Node.left], 0
    mov qword [rax+Node.right], 0
    mov dword [rax+Node.val], r13d
    mov [rbx+Node.left], rax
    jmp .done

.left_recurse:
    mov rdi, r12
    mov esi, r13d
    call insert
    jmp .done

.go_right:
    mov r12, [rbx+Node.right]
    test r12, r12
    jnz .right_recurse
    
    mov edi, Node_size
    call malloc
    mov qword [rax+Node.left], 0
    mov qword [rax+Node.right], 0
    mov dword [rax+Node.val], r13d
    mov [rbx+Node.right], rax
    jmp .done

.right_recurse:
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
