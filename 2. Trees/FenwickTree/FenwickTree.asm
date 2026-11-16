; Array-backed prefix sums with point-add updates.
extern exit, free

BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc, scanf, printf

section .data
    fmt_d db "%d",0
    fmt_out db "%lld ",0
    newline db 10,0

section .bss
    n resd 1
    q resd 1
    tree resq 1

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
    sub rsp, 16

    lea rdi, [fmt_d]
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
    inc eax
    mov edi, eax
    shl edi, 3
    call malloc
    test rax, rax
    jz allocation_error
    mov [tree], rax

    mov rcx, [tree]
    mov eax, [n]
    inc eax
    xor edx, edx
.zero_loop:
    cmp edx, eax
    jge .read_array
    mov qword [rcx + 8*rdx], 0
    inc edx
    jmp .zero_loop

.read_array:
    mov r12d, 1
.array_loop:
    cmp r12d, [n]
    jg .read_queries

    lea rdi, [fmt_d]
    lea rsi, [rbp-4]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne input_error

    mov edi, [rbp-4]
    mov esi, r12d
    call update_bit

    inc r12d
    jmp .array_loop

.read_queries:
    lea rdi, [fmt_d]
    lea rsi, [q]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne input_error

    cmp dword [q], 0
    jl input_error
    mov r12d, 0
.query_loop:
    cmp r12d, [q]
    jge .end

    lea rdi, [fmt_d]
    lea rsi, [rbp-4]
    xor eax, eax
    call scanf
    cmp eax, 1
    jne input_error

    mov edi, [rbp-4]
    test edi, edi
    js input_error
    cmp edi, [n]
    jge input_error
    inc edi
    call query_bit

    lea rdi, [fmt_out]
    mov rsi, rax
    xor eax, eax
    call printf

    inc r12d
    jmp .query_loop

.end:
    lea rdi, [newline]
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

update_bit:
    push rbp
    mov rbp, rsp
    push rbx

    mov rbx, [tree]
    mov eax, esi
    movsxd rdi, edi

.update_loop:
    cmp eax, [n]
    jg .update_done

    add qword [rbx + 8*rax], rdi

    mov ecx, eax
    neg ecx
    and ecx, eax
    add eax, ecx
    jmp .update_loop

.update_done:
    pop rbx
    pop rbp
    ret

query_bit:
    push rbp
    mov rbp, rsp
    push rbx

    mov rbx, [tree]
    mov eax, edi
    xor edx, edx

.query_loop:
    test eax, eax
    jz .query_done

    add rdx, qword [rbx + 8*rax]

    mov ecx, eax
    neg ecx
    and ecx, eax
    sub eax, ecx
    jmp .query_loop

.query_done:
    mov rax, rdx
    pop rbx
    pop rbp
    ret

section .text
allocation_error:
    mov edi, 1
    call exit
    ud2
