; Fixed four-point leaf and inclusive range-search demonstration.
%define M 4
%define TYPE_LEAF 0
%define TYPE_INTERNAL 1

section .bss
align 8
root_node:    resb 1
              resb 1
              resb 6
              resq 4*M*5
leaf_node:    resb 1
              resb 1
              resb 6
              resq 4*M*5

section .data
pts:    dq 1,1, 2,2, 3,3, 4,4
np:     equ 4
fmt:    db "Point %d: (%ld,%ld)",10,0

section .text
global main
extern printf

init_tree:
    mov byte [root_node], TYPE_INTERNAL
    mov byte [root_node+1], 1
    mov byte [leaf_node], TYPE_LEAF
    mov byte [leaf_node+1], 0
    ret

insert_point:
    push rbx

    mov al, [leaf_node]
    cmp al, TYPE_LEAF
    jne .ret
    movzx rcx, byte [leaf_node+1]
    cmp rcx, M
    jae .ret

    mov rax, rcx
    imul rax, 40
    lea rbx, [leaf_node+8]
    add rbx, rax

    mov qword [rbx+0], rdi
    mov qword [rbx+8], rsi
    mov qword [rbx+16], rdi
    mov qword [rbx+24], rsi
    mov qword [rbx+32], rcx
    inc byte [leaf_node+1]
.ret:
    pop rbx
    ret

range_search:
    push rbx
    push rbp

    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    mov r15, rcx

    movzx rbx, byte [leaf_node+1]
    xor rbp, rbp
.loop:
    cmp rbp, rbx
    jge .done

    mov r8, rbp
    imul r8, 40
    lea r9, [leaf_node+8]
    add r9, r8

    mov r10, [r9+0]
    mov r11, [r9+8]
    mov rax, [r9+16]
    mov rcx, [r9+24]

    cmp r14, r10
    jl .next
    cmp r12, rax
    jg .next
    cmp r15, r11
    jl .next
    cmp r13, rcx
    jg .next

    push rbx
    push rbp
    push r9

    mov rsi, [r9+32]

    mov rdx, [r9]
    mov rcx, [r9+8]

    lea rdi, [fmt]
    xor rax, rax
    call printf
    pop r9
    pop rbp
    pop rbx
.next:
    inc rbp
    jmp .loop
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    ret

main:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    push rbp
    mov rbp, rsp

    call init_tree

    xor r12, r12
.insert_loop:
    cmp r12, np
    jge .do_search

    mov rax, r12
    imul rax, 16
    lea rbx, [pts]
    add rbx, rax

    mov rdi, [rbx]
    mov rsi, [rbx+8]
    push r12
    call insert_point
    pop r12
    inc r12
    jmp .insert_loop
.do_search:

    mov rdi, 2
    mov rsi, 2
    mov rdx, 3
    mov rcx, 3
    call range_search

    xor rax, rax
    pop rbp
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
section .note.GNU-stack noalloc noexec nowrite progbits
