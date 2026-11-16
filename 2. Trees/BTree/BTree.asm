BITS 64
default rel
extern calloc, free, printf, exit

; Node: count (dword), leaf (dword), keys (pointer), children (pointer).
%define COUNT 0
%define LEAF 4
%define KEYS 8
%define CHILDREN 16

section .note.GNU-stack noalloc noexec nowrite progbits
section .data
    fmt_out db "%d ", 0
    newline db 10, 0
section .bss
    t resd 1
    n resd 1
    temp resd 1
    root resq 1
section .text
global main
main:
    push rbx
    lea rdi, [t]
    call tree_read_int
    cmp eax, 1
    jne .error
    cmp dword [t], 2
    jl .error
    lea rdi, [n]
    call tree_read_int
    cmp eax, 1
    jne .error
    cmp dword [n], 0
    jl .error
    cmp dword [n], 268435455
    jg .error
    xor ebx, ebx
.read:
    cmp ebx, [n]
    jge .print
    lea rdi, [temp]
    call tree_read_int
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
    call inorder
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
    push r12
    sub rsp, 8
    mov r12d, edi
    mov edi, 1
    mov esi, 24
    call calloc
    test rax, rax
    jz allocation_error
    mov rbx, rax
    mov [rbx + LEAF], r12d
    mov edi, [t]
    lea rdi, [rdi*2-1]
    mov esi, 4
    call calloc
    test rax, rax
    jz allocation_error
    mov [rbx + KEYS], rax
    mov edi, [t]
    add rdi, rdi
    mov esi, 8
    call calloc
    test rax, rax
    jz allocation_error
    mov [rbx + CHILDREN], rax
    mov rax, rbx
    add rsp, 8
    pop r12
    pop rbx
    ret

; Split a full child before descending into it.
split_child:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    mov r13d, esi
    mov rax, [r12 + CHILDREN]
    mov r14, [rax + r13*8]
    mov edi, [r14 + LEAF]
    call new_node
    mov r15, rax
    mov ebx, [t]
    lea eax, [rbx-1]
    mov [r14 + COUNT], eax
    mov [r15 + COUNT], eax
    xor ecx, ecx
.copy_keys:
    lea edx, [rbx-1]
    cmp ecx, edx
    jge .children
    mov rsi, [r14 + KEYS]
    mov rdi, [r15 + KEYS]
    lea edx, [rbx+rcx]
    mov eax, [rsi + rdx*4]
    mov [rdi + rcx*4], eax
    inc ecx
    jmp .copy_keys
.children:
    cmp dword [r14 + LEAF], 0
    jne .shift_children
    xor ecx, ecx
.copy_children:
    cmp ecx, ebx
    jge .shift_children
    mov rsi, [r14 + CHILDREN]
    mov rdi, [r15 + CHILDREN]
    lea edx, [rbx+rcx]
    mov rax, [rsi + rdx*8]
    mov [rdi + rcx*8], rax
    inc ecx
    jmp .copy_children
.shift_children:
    mov ecx, [r12 + COUNT]
    mov rdi, [r12 + CHILDREN]
.shift_child:
    cmp ecx, r13d
    jle .set_child
    mov rax, [rdi + rcx*8]
    mov [rdi + rcx*8+8], rax
    dec ecx
    jmp .shift_child
.set_child:
    mov [rdi + r13*8+8], r15
    mov ecx, [r12 + COUNT]
    mov rdi, [r12 + KEYS]
.shift_key:
    cmp ecx, r13d
    jle .median
    mov eax, [rdi + rcx*4-4]
    mov [rdi + rcx*4], eax
    dec ecx
    jmp .shift_key
.median:
    mov rsi, [r14 + KEYS]
    mov eax, [rsi + rbx*4-4]
    mov [rdi + r13*4], eax
    inc dword [r12 + COUNT]
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

insert:
    push rbx
    push r12
    sub rsp, 8
    mov rbx, rdi
    mov r12d, esi
    test rbx, rbx
    jnz .check_full
    mov edi, 1
    call new_node
    mov rbx, rax
.check_full:
    mov eax, [t]
    lea eax, [rax*2-1]
    cmp [rbx + COUNT], eax
    jne .descend
    xor edi, edi
    call new_node
    mov rdi, [rax + CHILDREN]
    mov [rdi], rbx
    mov rbx, rax
    mov rdi, rbx
    xor esi, esi
    call split_child
.descend:
    mov rdi, rbx
    mov esi, r12d
    call insert_nonfull
    mov rax, rbx
    add rsp, 8
    pop r12
    pop rbx
    ret

insert_nonfull:
    push rbx
    push r12
    push r13
    mov rbx, rdi
    mov r12d, esi
    mov r13d, [rbx + COUNT]
    mov rdx, [rbx + KEYS]
    cmp dword [rbx + LEAF], 0
    je .find_child
.leaf_shift:
    test r13d, r13d
    jz .set_key
    cmp r12d, [rdx + r13*4-4]
    jge .set_key
    mov eax, [rdx + r13*4-4]
    mov [rdx + r13*4], eax
    dec r13d
    jmp .leaf_shift
.set_key:
    mov [rdx + r13*4], r12d
    inc dword [rbx + COUNT]
    jmp .done
.find_child:
    test r13d, r13d
    jz .check_child
    cmp r12d, [rdx + r13*4-4]
    jge .check_child
    dec r13d
    jmp .find_child
.check_child:
    mov rax, [rbx + CHILDREN]
    mov rdi, [rax + r13*8]
    mov eax, [t]
    lea eax, [rax*2-1]
    cmp [rdi + COUNT], eax
    jne .recurse
    mov rdi, rbx
    mov esi, r13d
    call split_child
    mov rdx, [rbx + KEYS]
    cmp r12d, [rdx + r13*4]
    jl .child_ready
    inc r13d
.child_ready:
    mov rax, [rbx + CHILDREN]
    mov rdi, [rax + r13*8]
.recurse:
    mov esi, r12d
    call insert_nonfull
.done:
    pop r13
    pop r12
    pop rbx
    ret

inorder:
    test rdi, rdi
    jz .return
    push rbx
    push r12
    sub rsp, 8
    mov rbx, rdi
    xor r12d, r12d
.loop:
    cmp dword [rbx + LEAF], 0
    jne .key
    mov rax, [rbx + CHILDREN]
    mov rdi, [rax + r12*8]
    call inorder
.key:
    cmp r12d, [rbx + COUNT]
    jge .done
    mov rax, [rbx + KEYS]
    mov esi, [rax + r12*4]
    lea rdi, [fmt_out]
    xor eax, eax
    call printf
    inc r12d
    jmp .loop
.done:
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
    mov rax, [rbx + CHILDREN]
    mov rdi, [rax + r12*8]
    call destroy
    inc r12d
    cmp r12d, [rbx + COUNT]
    jle .children
.release:
    mov rdi, [rbx + KEYS]
    call free
    mov rdi, [rbx + CHILDREN]
    call free
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
