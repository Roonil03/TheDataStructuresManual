;Tries
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc
extern scanf
extern printf

section .data
    fmt_int     db "%d", 0
    fmt_str     db "%s", 0
    fmt_found   db "Found: %s", 10, 0
    fmt_not     db "Not found: %s", 10, 0
    
    NODE_SIZE   equ 216     ; 8 (flag) + 26*8 (pointers)
    
section .bss
    root        resq 1      ; Root node pointer
    buffer      resb 256    ; Input buffer
    word_count  resd 1      ; Number of words

section .text
    global main

; Create a new trie node - FIXED VERSION
; Returns: RAX = pointer to new node
create_node:
    push rbp
    mov rbp, rsp
    
    mov edi, NODE_SIZE
    call malloc
    test rax, rax
    jz .error
    
    ; Save original pointer before rep stosb
    push rax
    mov rdi, rax
    mov rcx, NODE_SIZE
    xor al, al
    rep stosb
    pop rax              ; Restore original pointer
    
    pop rbp
    ret
    
.error:
    xor eax, eax
    pop rbp
    ret

; Insert a string into the trie
; RDI = root node, RSI = string pointer
insert:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    
    mov rbx, rdi        ; rbx = current node
    mov r12, rsi        ; r12 = string pointer
    xor r13, r13        ; r13 = index into string
    
.loop:
    mov al, [r12 + r13]
    test al, al
    jz .end_of_string
    
    ; Convert to index (a=0, b=1, etc.)
    sub al, 'a'
    movzx r14, al       ; Use r14 (64-bit) for indexing
    
    ; Check if child exists
    mov rcx, [rbx + 8 + r14*8]
    test rcx, rcx
    jnz .child_exists
    
    ; Create new node
    call create_node
    test rax, rax       ; Check if malloc failed
    jz .done
    
    ; Store pointer to new node
    mov [rbx + 8 + r14*8], rax
    mov rcx, rax
    
.child_exists:
    mov rbx, rcx        ; Move to child node
    inc r13             ; Next character
    jmp .loop
    
.end_of_string:
    mov qword [rbx], 1  ; Mark as end of word
    
.done:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Search for a string in the trie
; RDI = root node, RSI = string pointer
; Returns: RAX = 1 if found, 0 if not found
search:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    
    mov rbx, rdi        ; rbx = current node
    mov r12, rsi        ; r12 = string pointer
    xor r13, r13        ; r13 = index into string
    
.loop:
    test rbx, rbx
    jz .not_found
    
    mov al, [r12 + r13]
    test al, al
    jz .end_of_string
    
    ; Convert to index
    sub al, 'a'
    movzx r14, al       ; Use r14 (64-bit) for indexing
    
    ; Move to child
    mov rbx, [rbx + 8 + r14*8]
    inc r13
    jmp .loop
    
.end_of_string:
    ; Check if this is marked as end of word
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

; Main function
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Create root node
    call create_node
    test rax, rax
    jz .error_exit
    mov [root], rax
    
    ; Read number of words to insert
    lea rdi, [fmt_int]
    lea rsi, [word_count]
    xor eax, eax
    call scanf
    
    ; Read and insert words
    xor r12d, r12d      ; Counter
    
.read_loop:
    cmp r12d, [word_count]
    jge .search_phase
    
    ; Read word
    lea rdi, [fmt_str]
    lea rsi, [buffer]
    xor eax, eax
    call scanf
    
    ; Insert into trie
    mov rdi, [root]
    lea rsi, [buffer]
    call insert
    
    inc r12d
    jmp .read_loop
    
.search_phase:
    ; Read number of searches
    lea rdi, [fmt_int]
    lea rsi, [word_count]
    xor eax, eax
    call scanf
    
    ; Read and search words
    xor r12d, r12d      ; Counter
    
.search_loop:
    cmp r12d, [word_count]
    jge .done
    
    ; Read word
    lea rdi, [fmt_str]
    lea rsi, [buffer]
    xor eax, eax
    call scanf
    
    ; Search in trie
    mov rdi, [root]
    lea rsi, [buffer]
    call search
    
    ; Print result
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
    xor eax, eax
    leave
    ret

.error_exit:
    mov eax, 1
    leave
    ret
