; suffixtree.asm
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc
extern scanf
extern printf
extern strlen

section .data
    fmt_str     db "%s", 0
    fmt_found   db "Found at position %d", 10, 0
    fmt_not     db "Pattern not found", 10, 0
    
section .bss
    text        resb 1024   ; Input text
    pattern     resb 256    ; Search pattern
    suffixes    resq 1000   ; Array of suffix pointers
    suffix_count resd 1     ; Number of suffixes

section .text
    global main

; Create suffix array
; RDI = text pointer
create_suffix_array:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    mov rbx, rdi            ; rbx = text
    
    ; Get text length
    call strlen
    mov r12, rax            ; r12 = text length
    mov [suffix_count], eax
    
    ; Create suffixes
    xor r13, r13            ; r13 = i = 0
    
.suffix_loop:
    cmp r13, r12
    jge .done
    
    ; Calculate suffix position and store
    lea rax, [rbx + r13]    ; rax = text + i
    lea rcx, [suffixes]     ; rcx = suffixes array
    mov [rcx + r13*8], rax  ; suffixes[i] = text + i
    
    inc r13
    jmp .suffix_loop
    
.done:
    mov eax, 1
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Search for pattern in suffix array
; RDI = pattern pointer
; Returns: EAX = position if found, -1 if not found
search_pattern:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    
    mov rbx, rdi            ; rbx = pattern
    
    ; Get pattern length
    call strlen
    mov r12, rax            ; r12 = pattern length
    
    ; Search through all suffixes
    xor r13, r13            ; r13 = i = 0
    
.search_loop:
    mov eax, [suffix_count]
    cmp r13d, eax
    jge .not_found
    
    ; Get current suffix pointer
    lea rax, [suffixes]
    mov r14, [rax + r13*8]  ; r14 = suffix string
    
    ; Compare pattern with suffix
    mov rdi, r14            ; current suffix
    mov rsi, rbx            ; pattern
    mov rdx, r12            ; pattern length
    call my_strncmp
    
    test eax, eax
    jz .found               ; my_strncmp returns 0 on match
    
    inc r13
    jmp .search_loop
    
.found:
    mov eax, r13d
    jmp .exit
    
.not_found:
    mov eax, -1
    
.exit:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Fixed strncmp implementation
; RDI = str1, RSI = str2, RDX = n
; Returns: EAX = 0 if equal, non-zero otherwise
my_strncmp:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push r8
    
    mov rbx, rdi            ; rbx = str1 (preserve)
    mov r8, rsi             ; r8 = str2 (preserve)
    xor rcx, rcx            ; rcx = counter
    
.compare_loop:
    cmp rcx, rdx
    jge .equal
    
    mov al, [rbx + rcx]     ; Load from str1
    mov dil, [r8 + rcx]     ; Load from str2 (use dil to avoid rbx corruption)
    cmp al, dil
    jne .not_equal
    
    ; Check for null terminator
    test al, al
    jz .equal
    
    inc rcx
    jmp .compare_loop
    
.equal:
    xor eax, eax
    jmp .exit
    
.not_equal:
    mov eax, 1
    
.exit:
    pop r8
    pop rcx
    pop rbx
    pop rbp
    ret

; Main function
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Read input text
    lea rdi, [fmt_str]
    lea rsi, [text]
    xor eax, eax
    call scanf
    
    ; Create suffix array
    lea rdi, [text]
    call create_suffix_array
    test eax, eax
    jz .error
    
    ; Read search pattern
    lea rdi, [fmt_str]
    lea rsi, [pattern]
    xor eax, eax
    call scanf
    
    ; Search for pattern
    lea rdi, [pattern]
    call search_pattern
    
    ; Print result
    cmp eax, -1
    je .not_found
    
    lea rdi, [fmt_found]
    mov esi, eax
    xor eax, eax
    call printf
    jmp .done
    
.not_found:
    lea rdi, [fmt_not]
    xor eax, eax
    call printf
    jmp .done
    
.error:
    lea rdi, [fmt_not]
    xor eax, eax
    call printf
    
.done:
    xor eax, eax
    leave
    ret
