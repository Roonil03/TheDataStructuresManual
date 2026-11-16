; Each node labels its incoming edge with a text slice and stores the earliest suffix below it.
BITS 64
default rel

extern scanf, printf, strlen
global main

struc Node
    .child:   resq 1
    .sibling: resq 1
    .start:   resd 1
    .end:     resd 1
    .first:   resd 1
    .padding: resd 1
endstruc

section .rodata
    fmt_text  db "%999s", 0
    fmt_query db "%255s", 0
    fmt_found db "Found at position %d", 10, 0
    fmt_miss  db "Pattern not found", 10, 0

section .bss
    nodes   resb 2000 * Node_size
    used    resd 1
    text    resb 1000
    pattern resb 256

section .text

new_node:
    mov eax, [used]
    inc dword [used]
    imul eax, Node_size
    lea rcx, [nodes]
    add rax, rcx
    mov qword [rax + Node.child], 0
    mov qword [rax + Node.sibling], 0
    mov [rax + Node.start], edi
    mov [rax + Node.end], esi
    mov [rax + Node.first], edx
    ret

build_tree:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi
    lea rbx, [text]
    mov dword [used], 1
    mov qword [nodes + Node.child], 0
    xor r13d, r13d
.suffix:
    cmp r13d, r12d
    jae .done
    mov r14d, r13d
    lea r15, [nodes + Node.child]
.find_child:
    mov r8, [r15]
    test r8, r8
    jz .append_leaf
    mov ecx, [r8 + Node.start]
    mov al, [rbx + rcx]
    cmp al, [rbx + r14]
    je .match_edge
    lea r15, [r8 + Node.sibling]
    jmp .find_child
.match_edge:
    mov edx, r14d
.match_byte:
    cmp ecx, [r8 + Node.end]
    je .descend
    cmp edx, r12d
    je .next_suffix
    mov al, [rbx + rcx]
    cmp al, [rbx + rdx]
    jne .split
    inc ecx
    inc edx
    jmp .match_byte
.descend:
    cmp edx, r12d
    je .next_suffix
    mov r14d, edx
    lea r15, [r8 + Node.child]
    jmp .find_child
.split:
    mov r14d, edx
    mov esi, ecx
    mov edi, [r8 + Node.start]
    mov [r8 + Node.start], ecx
    mov edx, [r8 + Node.first]
    call new_node
    mov [r15], rax
    mov rcx, [r8 + Node.sibling]
    mov [rax + Node.sibling], rcx
    mov qword [r8 + Node.sibling], 0
    mov [rax + Node.child], r8
    lea r15, [r8 + Node.sibling]
.append_leaf:
    mov edi, r14d
    mov esi, r12d
    mov edx, r13d
    call new_node
    mov [r15], rax
.next_suffix:
    inc r13d
    jmp .suffix
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

search_pattern:
    lea r9, [text]
    mov r8, [nodes + Node.child]
.child:
    test r8, r8
    jz .miss
    mov ecx, [r8 + Node.start]
    mov al, [r9 + rcx]
    cmp al, [rdi]
    je .edge
    mov r8, [r8 + Node.sibling]
    jmp .child
.edge:
    inc ecx
    inc rdi
    cmp byte [rdi], 0
    je .found
    cmp ecx, [r8 + Node.end]
    je .descend
    mov al, [r9 + rcx]
    cmp al, [rdi]
    je .edge
.miss:
    mov eax, -1
    ret
.descend:
    mov r8, [r8 + Node.child]
    jmp .child
.found:
    mov eax, [r8 + Node.first]
    ret

main:
    sub rsp, 8
    lea rdi, [fmt_text]
    lea rsi, [text]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne .invalid
    lea rdi, [fmt_query]
    lea rsi, [pattern]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne .invalid
    lea rdi, [text]
    call strlen
    mov edi, eax
    call build_tree
    lea rdi, [pattern]
    call search_pattern
    lea rdi, [fmt_miss]
    test eax, eax
    js .print
    mov esi, eax
    lea rdi, [fmt_found]
.print:
    xor eax, eax
    call printf
    xor eax, eax
    jmp .done
.invalid:
    mov eax, 1
.done:
    add rsp, 8
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
