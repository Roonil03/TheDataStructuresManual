BITS 64
default rel
extern calloc, free, scanf, printf, exit

; Order 3; arrays include one temporary overflow slot.
%define COUNT 0
%define LEAF 4
%define KEYS 8
%define CHILDREN 24
%define NEXT 56
%define NODE_SIZE 64

section .note.GNU-stack noalloc noexec nowrite progbits
section .data
    fmt_int db "%d", 0
    fmt_out db "%d ", 0
    newline db 10, 0
section .bss
    root resq 1
    temp resd 1
    key_count resd 1
section .text
global main
main:
    push rbx
    lea rdi, [fmt_int]
    lea rsi, [key_count]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne .error
    cmp dword [key_count], 0
    jl .error
    cmp dword [key_count], 536870911
    jg .error
    xor ebx, ebx
.read:
    cmp ebx, [key_count]
    jge .print
    lea rdi, [fmt_int]
    lea rsi, [temp]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne .error
    mov rdi, [root]
    mov esi, [temp]
    call insert
    mov [root], rax
    inc ebx
    jmp .read
.print:
    mov rdi, [root]
    call print_leaves
    lea rdi, [newline]
    xor eax, eax
    call printf
    xor ebx, ebx
    jmp .done
.error:
    mov ebx, 1
.done:
    mov rdi, [root]
    call destroy
    mov eax, ebx
    pop rbx
    ret

new_node:
    push rbx
    mov ebx, edi
    mov edi, 1
    mov esi, NODE_SIZE
    call calloc
    test rax, rax
    jz allocation_error
    mov [rax + LEAF], ebx
    pop rbx
    ret

insert:
    push rbx
    push r12
    sub rsp, 8
    mov rbx, rdi
    mov r12d, esi
    test rbx, rbx
    jnz .insert
    mov edi, 1
    call new_node
    mov rbx, rax
.insert:
    mov rdi, rbx
    mov esi, r12d
    call insert_node
    test rax, rax
    jz .done
    mov r12, rax
    mov [rsp], edx
    xor edi, edi
    call new_node
    mov dword [rax + COUNT], 1
    mov edx, [rsp]
    mov [rax + KEYS], edx
    mov [rax + CHILDREN], rbx
    mov [rax + CHILDREN+8], r12
    mov rbx, rax
.done:
    mov rax, rbx
    add rsp, 8
    pop r12
    pop rbx
    ret

; Returns a new right sibling in RAX and its separator in EDX, or zero.
insert_node:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12d, esi
    mov r13d, [rbx + COUNT]
    cmp dword [rbx + LEAF], 0
    je .find_child
.leaf_shift:
    test r13d, r13d
    jz .leaf_set
    cmp r12d, [rbx + KEYS + r13*4-4]
    jge .leaf_set
    mov eax, [rbx + KEYS + r13*4-4]
    mov [rbx + KEYS + r13*4], eax
    dec r13d
    jmp .leaf_shift
.leaf_set:
    mov [rbx + KEYS + r13*4], r12d
    inc dword [rbx + COUNT]
    cmp dword [rbx + COUNT], 3
    jl .no_split
    mov edi, 1
    call new_node
    mov dword [rax + COUNT], 2
    mov edx, [rbx + KEYS+4]
    mov [rax + KEYS], edx
    mov ecx, [rbx + KEYS+8]
    mov [rax + KEYS+4], ecx
    mov rcx, [rbx + NEXT]
    mov [rax + NEXT], rcx
    mov [rbx + NEXT], rax
    mov dword [rbx + COUNT], 1
    jmp .done
.find_child:
    test r13d, r13d
    jz .recurse
    cmp r12d, [rbx + KEYS + r13*4-4]
    jge .recurse
    dec r13d
    jmp .find_child
.recurse:
    mov rdi, [rbx + CHILDREN + r13*8]
    mov esi, r12d
    call insert_node
    test rax, rax
    jz .no_split
    mov ecx, [rbx + COUNT]
.shift:
    cmp ecx, r13d
    jle .set_separator
    mov esi, [rbx + KEYS + rcx*4-4]
    mov [rbx + KEYS + rcx*4], esi
    mov rsi, [rbx + CHILDREN + rcx*8]
    mov [rbx + CHILDREN + rcx*8+8], rsi
    dec ecx
    jmp .shift
.set_separator:
    mov [rbx + KEYS + r13*4], edx
    mov [rbx + CHILDREN + r13*8+8], rax
    inc dword [rbx + COUNT]
    cmp dword [rbx + COUNT], 3
    jl .no_split
    xor edi, edi
    call new_node
    mov dword [rax + COUNT], 1
    mov edx, [rbx + KEYS+8]
    mov [rax + KEYS], edx
    mov rdx, [rbx + CHILDREN+16]
    mov [rax + CHILDREN], rdx
    mov rdx, [rbx + CHILDREN+24]
    mov [rax + CHILDREN+8], rdx
    mov edx, [rbx + KEYS+4]
    mov dword [rbx + COUNT], 1
    jmp .done
.no_split:
    xor eax, eax
.done:
    pop r13
    pop r12
    pop rbx
    ret

print_leaves:
    test rdi, rdi
    jz .return
    push rbx
    push r12
    sub rsp, 8
    mov rbx, rdi
.first:
    cmp dword [rbx + LEAF], 0
    jne .leaf
    mov rbx, [rbx + CHILDREN]
    jmp .first
.leaf:
    xor r12d, r12d
.key:
    cmp r12d, [rbx + COUNT]
    jge .next
    lea rdi, [fmt_out]
    mov esi, [rbx + KEYS + r12*4]
    xor eax, eax
    call printf
    inc r12d
    jmp .key
.next:
    mov rbx, [rbx + NEXT]
    test rbx, rbx
    jnz .leaf
    add rsp, 8
    pop r12
    pop rbx
.return:
    ret

destroy:
    test rdi, rdi
    jz .return
    push rbx
    push r12
    sub rsp, 8
    mov rbx, rdi
    xor r12d, r12d
    cmp dword [rbx + LEAF], 0
    jne .release
.children:
    mov rdi, [rbx + CHILDREN + r12*8]
    call destroy
    inc r12d
    cmp r12d, [rbx + COUNT]
    jle .children
.release:
    mov rdi, rbx
    call free
    add rsp, 8
    pop r12
    pop rbx
.return:
    ret

allocation_error:
    mov edi, 1
    call exit
    ud2
