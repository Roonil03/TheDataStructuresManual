; fenwick.asm
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

extern malloc, scanf, printf

section .data
    fmt_d db "%d",0
    fmt_out db "%d ",0
    newline db 10,0

section .bss
    n resd 1
    q resd 1
    tree resq 1

section .text
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; read n
    lea rdi, [fmt_d]
    lea rsi, [n]
    xor eax, eax
    call scanf

    ; allocate tree (n+1 elements)
    mov eax, [n]
    inc eax
    mov edi, eax
    shl edi, 2
    call malloc
    mov [tree], rax

    ; zero initialize
    mov rcx, [tree]
    mov eax, [n]
    inc eax
    xor edx, edx
.zero_loop:
    cmp edx, eax
    jge .read_array
    mov dword [rcx + 4*rdx], 0
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

    mov r12d, 0
.query_loop:
    cmp r12d, [q]
    jge .end

    lea rdi, [fmt_d]
    lea rsi, [rbp-4]
    xor eax, eax
    call scanf
    
    mov edi, [rbp-4]
    inc edi
    call query_bit
    
    lea rdi, [fmt_out]
    mov esi, eax
    xor eax, eax
    call printf
    
    inc r12d
    jmp .query_loop

.end:
    lea rdi, [newline]
    xor eax, eax
    call printf
    leave
    ret

; update_bit(val, idx) - add val to index idx
update_bit:
    push rbp
    mov rbp, rsp
    push rbx
    
    mov rbx, [tree]
    mov eax, esi
    
.update_loop:
    cmp eax, [n]
    jg .update_done
    
    add dword [rbx + 4*rax], edi
    
    ; i += i & (-i)
    mov ecx, eax
    neg ecx
    and ecx, eax
    add eax, ecx
    jmp .update_loop
    
.update_done:
    pop rbx
    pop rbp
    ret

; query_bit(idx) - get prefix sum up to idx
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
    
    add edx, dword [rbx + 4*rax]
    
    ; i -= i & (-i)
    mov ecx, eax
    neg ecx
    and ecx, eax
    sub eax, ecx
    jmp .query_loop
    
.query_done:
    mov eax, edx
    pop rbx
    pop rbp
    ret
