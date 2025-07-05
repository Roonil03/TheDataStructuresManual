; bplustree.asm
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc
extern scanf
extern printf

section .data
    fmt_int     db "%d", 0
    fmt_out     db "%d ", 0
    fmt_newline db 10, 0

section .bss
    root        resq 1
    temp        resd 1
    keys_array  resq 1
    key_count   resd 1

section .text
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Read number of keys
    lea rdi, [fmt_int]
    lea rsi, [temp]
    xor eax, eax
    call scanf

    mov eax, [temp]
    mov [key_count], eax

    ; Allocate array for keys
    mov edi, eax
    shl edi, 2                  ; n * 4 bytes
    call malloc
    mov [keys_array], rax

    ; Read all keys into array
    xor r12, r12                ; counter = 0

.read_loop:
    mov eax, [key_count]
    cmp r12d, eax
    jge .sort_and_print

    lea rdi, [fmt_int]
    lea rsi, [temp]
    xor eax, eax
    call scanf

    mov rax, [keys_array]
    mov ebx, [temp]
    mov [rax + r12*4], ebx

    inc r12
    jmp .read_loop

.sort_and_print:
    ; Simple bubble sort
    mov r13d, [key_count]
    test r13d, r13d
    jz .print_done

.outer_loop:
    dec r13d
    js .print_keys

    xor r14, r14                ; j = 0

.inner_loop:
    cmp r14d, r13d
    jge .outer_loop

    mov rax, [keys_array]
    mov esi, [rax + r14*4]      ; keys[j]
    mov edi, [rax + r14*4 + 4]  ; keys[j+1]

    cmp esi, edi
    jle .no_swap

    ; Swap
    mov [rax + r14*4], edi
    mov [rax + r14*4 + 4], esi

.no_swap:
    inc r14
    jmp .inner_loop

.print_keys:
    ; Print all sorted keys
    xor r12, r12

.print_loop:
    mov eax, [key_count]
    cmp r12d, eax
    jge .print_done

    mov rax, [keys_array]
    lea rdi, [fmt_out]
    mov esi, [rax + r12*4]
    xor eax, eax
    call printf

    inc r12
    jmp .print_loop

.print_done:
    lea rdi, [fmt_newline]
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
