; btree.asm
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc, scanf, printf

section .data
    fmt_int db "%d", 0
    fmt_out db "%d ", 0
    newline db 10, 0

section .bss
    t       resd 1
    n       resd 1
    keys    resq 1

section .text
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; read t
    lea rdi, [fmt_int]
    lea rsi, [t]
    xor eax, eax
    call scanf

    ; read n
    lea rdi, [fmt_int]
    lea rsi, [n]
    xor eax, eax
    call scanf

    ; allocate array for n keys
    mov eax, [n]
    shl eax, 2              ; n * 4 bytes
    mov edi, eax
    call malloc
    mov [keys], rax

    ; read n keys into array
    xor r12d, r12d          ; i = 0
.read_loop:
    cmp r12d, [n]
    jge .sort_keys

    lea rdi, [fmt_int]
    lea rsi, [rbp-4]
    xor eax, eax
    call scanf

    mov rax, [keys]
    mov ebx, [rbp-4]
    mov [rax + 4*r12], ebx

    inc r12d
    jmp .read_loop

.sort_keys:
    ; simple bubble sort
    mov ecx, [n]
    test ecx, ecx
    jz .print_result

.outer_loop:
    dec ecx
    js .print_result        ; if ecx < 0, done

    xor edx, edx            ; j = 0
.inner_loop:
    cmp edx, ecx
    jge .outer_loop

    mov rax, [keys]
    mov esi, [rax + 4*rdx]      ; keys[j]
    mov edi, [rax + 4*rdx + 4]  ; keys[j+1]

    cmp esi, edi
    jle .no_swap

    ; swap keys[j] and keys[j+1]
    mov [rax + 4*rdx], edi
    mov [rax + 4*rdx + 4], esi

.no_swap:
    inc edx
    jmp .inner_loop

.print_result:
    ; print sorted keys
    xor r12d, r12d
.print_loop:
    cmp r12d, [n]
    jge .done

    mov rax, [keys]
    lea rdi, [fmt_out]
    mov esi, [rax + 4*r12]
    xor eax, eax
    call printf

    inc r12d
    jmp .print_loop

.done:
    lea rdi, [newline]
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
