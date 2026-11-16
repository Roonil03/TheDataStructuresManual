; Iterative range sums with leaves in the second half of the array.
extern exit, free

BITS 64
default rel
section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc, scanf, printf

section .data
    fmt_int db "%d",0
    fmt_ans db "%lld ",0
    fmt_nl  db 10,0

section .bss
    n       resd 1
    q       resd 1
    arr     resq 1
    tree    resq 1

section .text
    global main

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

    lea rdi, [fmt_int]
    lea rsi, [n]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne input_error
    cmp dword [n], 0
    jl input_error
    cmp dword [n], 268435455
    jg input_error

    mov eax, [n]
    mov edi, eax
    shl edi, 4
    call malloc
    test rax, rax
    jz allocation_error
    mov [tree], rax

    xor r12d, r12d
.LOAD:
    cmp r12d, [n]
    jge .BUILD
    lea rdi, [fmt_int]
    lea rsi, [rbp-4]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne input_error
    movsxd rcx, dword [rbp-4]
    mov rax, [tree]
    mov rsi, r12
    mov edx, [n]
    add rsi, rdx
    mov [rax + 8*rsi], rcx
    inc r12d
    jmp .LOAD

.BUILD:
    mov r12d, [n]
    dec r12d
.BUILD_LOOP:
    cmp r12d, 1
    jl .READ_Q
    mov rax, [tree]
    mov rsi, r12
    shl rsi, 1
    mov rbx, [rax + 8*rsi]
    inc rsi
    mov rdx, [rax + 8*rsi]
    add rbx, rdx
    mov [rax + 8*r12], rbx
    dec r12d
    jmp .BUILD_LOOP

.READ_Q:
    lea rdi, [fmt_int]
    lea rsi, [q]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne input_error

    cmp dword [q], 0
    jl input_error
    xor r12d, r12d
.QUERY_LOOP:
    cmp r12d, [q]
    jge .DONE
    lea rdi, [fmt_int]
    lea rsi, [rbp-8]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne input_error
    lea rdi, [fmt_int]
    lea rsi, [rbp-4]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne input_error

    mov edi, [rbp-8]
    mov esi, [rbp-4]
    test edi, edi
    js input_error
    cmp edi, esi
    jg input_error
    cmp esi, [n]
    jge input_error
    call query_range

    lea rdi, [fmt_ans]
    mov rsi, rax
    xor eax, eax
    call printf

    inc r12d
    jmp .QUERY_LOOP

.DONE:
    lea rdi, [fmt_nl]
    xor eax, eax
    call printf
    xor r12d, r12d
    jmp cleanup
input_error:
    mov r12d, 1
cleanup:
    mov rdi, [tree]
    call free
    mov qword [tree], 0
    mov eax, r12d
    leave
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

query_range:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    mov r12d, edi
    mov r13d, esi
    add r12d, [n]
    add r13d, [n]
    inc r13d
    xor eax, eax

.Q_LOOP:
    cmp r12d, r13d
    jge .Q_DONE
    test r12d, 1
    jz .CHK_R
    mov rbx, [tree]
    add rax, [rbx + 8*r12]
    inc r12d

.CHK_R:
    test r13d, 1
    jz .SHIFT
    dec r13d
    mov rbx, [tree]
    add rax, [rbx + 8*r13]

.SHIFT:
    shr r12d, 1
    shr r13d, 1
    jmp .Q_LOOP

.Q_DONE:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

section .text
allocation_error:
    mov edi, 1
    call exit
    ud2
