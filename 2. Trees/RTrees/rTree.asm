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
    ; rdi = x, rsi = y
    mov al, [leaf_node]
    cmp al, TYPE_LEAF
    jne .ret
    movzx rcx, byte [leaf_node+1]
    cmp rcx, M
    jae .ret
    ; Calculate entry offset: rcx * 40 (5 qwords * 8 bytes)
    mov rax, rcx
    imul rax, 40
    lea rbx, [leaf_node+8]
    add rbx, rax
    ; Store point MBR
    mov qword [rbx+0], rdi
    mov qword [rbx+8], rsi
    mov qword [rbx+16], rdi
    mov qword [rbx+24], rsi
    mov qword [rbx+32], rcx
    inc byte [leaf_node+1]
.ret:
    ret

range_search:
    ; Arguments: rdi=x1, rsi=y1, rdx=x2, rcx=y2
    ; Save search bounds
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi    ; x1
    mov r13, rsi    ; y1
    mov r14, rdx    ; x2
    mov r15, rcx    ; y2
    
    movzx rbx, byte [leaf_node+1]
    xor rbp, rbp
.loop:
    cmp rbp, rbx
    jge .done
    ; Calculate entry address
    mov r8, rbp
    imul r8, 40
    lea r9, [leaf_node+8]
    add r9, r8
    ; Load MBR
    mov r10, [r9+0]     ; xmin
    mov r11, [r9+8]     ; ymin
    mov rax, [r9+16]    ; xmax
    mov rcx, [r9+24]    ; ymax
    ; Test overlap
    cmp r14, r10
    jl .next
    cmp r12, rax
    jg .next
    cmp r15, r11
    jl .next
    cmp r13, rcx
    jg .next
    ; Found match - print it
    push rbx
    push rbp
    push r9
    ; Get point ID
    mov rsi, [r9+32]
    ; Calculate point address: pts + id*16
    mov rax, rsi
    imul rax, 16
    lea rcx, [pts]
    add rcx, rax
    ; Load coordinates
    mov rdx, [rcx]      ; x
    mov rcx, [rcx+8]    ; y
    ; printf(fmt, id, x, y)
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
    ret

main:
    push rbp
    mov rbp, rsp
    ; Initialize tree
    call init_tree
    ; Insert all points
    xor r12, r12
.insert_loop:
    cmp r12, np
    jge .do_search
    ; Calculate address: pts + r12*16
    mov rax, r12
    imul rax, 16
    lea rbx, [pts]
    add rbx, rax
    ; Load point
    mov rdi, [rbx]
    mov rsi, [rbx+8]
    push r12
    call insert_point
    pop r12
    inc r12
    jmp .insert_loop
.do_search:
    ; Search [2,2] to [3,3]
    mov rdi, 2
    mov rsi, 2
    mov rdx, 3
    mov rcx, 3
    call range_search
    ; Return 0
    xor rax, rax
    pop rbp
    ret
