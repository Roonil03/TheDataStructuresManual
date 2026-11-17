; Lowercase-word trie with terminal markers and exact-word lookup.
extern exit, free

BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc
extern printf

section .data
    fmt_found   db "Found: %s", 10, 0
    fmt_not     db "Not found: %s", 10, 0

    NODE_SIZE   equ 216

section .bss
    root        resq 1
    buffer      resb 256
    word_count  resd 1

section .text
    global main

create_node:
    push rbp
    mov rbp, rsp

    mov edi, NODE_SIZE
    call malloc
    test rax, rax
    jz allocation_error

    push rax
    mov rdi, rax
    mov rcx, NODE_SIZE
    xor al, al
    rep stosb
    pop rax

    pop rbp
    ret


insert:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi
    mov r12, rsi
    xor r13, r13

.loop:
    mov al, [r12 + r13]
    test al, al
    jz .end_of_string

    sub al, 'a'
    cmp al, 25
    ja .done
    movzx r14, al

    mov rcx, [rbx + 8 + r14*8]
    test rcx, rcx
    jnz .child_exists

    call create_node
    mov [rbx + 8 + r14*8], rax
    mov rcx, rax

.child_exists:
    mov rbx, rcx
    inc r13
    jmp .loop

.end_of_string:
    mov qword [rbx], 1

.done:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

search:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi
    mov r12, rsi
    xor r13, r13

.loop:
    test rbx, rbx
    jz .not_found

    mov al, [r12 + r13]
    test al, al
    jz .end_of_string

    sub al, 'a'
    cmp al, 25
    ja .not_found
    movzx r14, al

    mov rbx, [rbx + 8 + r14*8]
    inc r13
    jmp .loop

.end_of_string:

    mov rax, [rbx]
    jmp .done

.not_found:
    xor eax, eax

.done:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
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
    sub rsp, 32

    call create_node
    mov [root], rax

    lea rdi, [word_count]
    call tree_read_int
    cmp eax, 1
    jne input_error
    cmp dword [word_count], 0
    jl input_error

    xor r12d, r12d

.read_loop:
    cmp r12d, [word_count]
    jge .search_phase

    lea rdi, [buffer]
    mov esi, 256
    call tree_read_word
    cmp eax, 1
    jne input_error

    lea rdi, [buffer]
    call validate_word
    test eax, eax
    jz input_error

    mov rdi, [root]
    lea rsi, [buffer]
    call insert

    inc r12d
    jmp .read_loop

.search_phase:

    lea rdi, [word_count]
    call tree_read_int
    cmp eax, 1
    jne input_error
    cmp dword [word_count], 0
    jl input_error

    xor r12d, r12d

.search_loop:
    cmp r12d, [word_count]
    jge .done

    lea rdi, [buffer]
    mov esi, 256
    call tree_read_word
    cmp eax, 1
    jne input_error

    lea rdi, [buffer]
    call validate_word
    test eax, eax
    jz input_error

    mov rdi, [root]
    lea rsi, [buffer]
    call search

    test rax, rax
    jz .not_found_print

    lea rdi, [fmt_found]
    lea rsi, [buffer]
    xor eax, eax
    call printf
    jmp .next_search

.not_found_print:
    lea rdi, [fmt_not]
    lea rsi, [buffer]
    xor eax, eax
    call printf

.next_search:
    inc r12d
    jmp .search_loop

.done:
    xor r12d, r12d
    jmp cleanup
input_error:
    mov r12d, 1
cleanup:
    mov rdi, [root]
    call free_trie
    mov qword [root], 0
    mov eax, r12d
    leave
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

section .text
allocation_error:
    mov edi, 1
    call exit
    ud2

free_trie:
    test rdi, rdi
    jz .done
    push rbp
    push rbx
    push r12
    mov rbx, rdi
    xor r12d, r12d
.children:
    mov rdi, [rbx + 8 + r12*8]
    call free_trie
    inc r12d
    cmp r12d, 26
    jb .children
    mov rdi, rbx
    pop r12
    pop rbx
    pop rbp
    jmp free
.done:
    ret

; Validate the entire word before insertion can allocate any prefix nodes.
validate_word:
    movzx eax, byte [rdi]
    test eax, eax
    jz .valid
    sub eax, 'a'
    cmp eax, 25
    ja .invalid
    inc rdi
    jmp validate_word
.valid:
    mov eax, 1
    ret
.invalid:
    xor eax, eax
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
