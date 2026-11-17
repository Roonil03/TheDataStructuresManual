; Array-backed heap insertion and repeated root extraction.
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite

section .data
    fmt_out    db "%d ",0
    fmt_nl     db 10,0

section .bss
    n           resd 1
    heap        resd 400
    heap_size   resd 1

section .text
    extern printf
    global main

main:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    lea rdi, [rel n]
    call tree_read_int
    cmp eax, 1
    jne input_error
    cmp dword [n], 0
    jl input_error
    cmp dword [n], 400
    jg input_error

    mov     dword [rel heap_size], 0

    xor     r12d, r12d
.read_loop:
    cmp     r12d, dword [rel n]
    jge     .extract

    lea rdi, [rbp-4]
    call tree_read_int
    cmp eax, 1
    jne input_error
    mov     eax, [rbp-4]
    call    insert_heap

    inc     r12d
    jmp     .read_loop

.extract:
    xor     r12d, r12d
.print_loop:
    cmp     r12d, dword [rel n]
    jge     .done

    call    extract_max
    lea     rdi, [rel fmt_out]
    mov     esi, eax
    xor     eax, eax
    call    printf

    inc     r12d
    jmp     .print_loop

.done:
    lea     rdi, [rel fmt_nl]
    xor     eax, eax
    call    printf

    xor     eax, eax
    leave
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

input_error:
    mov eax, 1
    leave
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

insert_heap:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdx

    mov     ebx, dword [rel heap_size]
    mov     dword [heap + 4*rbx], eax
    inc     dword [rel heap_size]

    mov     ecx, ebx
.up:
    test    ecx, ecx
    jz      .done_up
    mov     edx, ecx
    dec     edx
    shr     edx, 1

    mov     eax, dword [heap + 4*ecx]
    mov     ebx, dword [heap + 4*edx]
    cmp     eax, ebx
    jle     .done_up

    mov     dword [heap + 4*ecx], ebx
    mov     dword [heap + 4*edx], eax
    mov     ecx, edx
    jmp     .up

.done_up:
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rbp
    ret

extract_max:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    rcx
    push    rdx
    push    r8
    push    r9

    mov     eax, dword [rel heap]

    mov     ebx, dword [rel heap_size]
    dec     ebx
    mov     ecx, dword [heap + 4*ebx]
    mov     dword [rel heap], ecx
    dec     dword [rel heap_size]

    cmp     dword [rel heap_size], 0
    je      .done_down

    xor     ecx, ecx
.down:

    mov     edx, ecx
    shl     edx, 1
    inc     edx
    cmp     edx, dword [rel heap_size]
    jge     .done_down

    mov     r8d, edx
    mov     r9d, dword [heap + 4*edx]
    inc     edx
    cmp     edx, dword [rel heap_size]
    jge     .chk_parent
    mov     ebx, dword [heap + 4*edx]
    cmp     ebx, r9d
    jle     .chk_parent
    mov     r8d, edx
    mov     r9d, ebx

.chk_parent:
    mov     ebx, dword [heap + 4*ecx]
    cmp     ebx, r9d
    jge     .done_down

    mov     dword [heap + 4*ecx], r9d
    mov     dword [heap + 4*r8], ebx
    mov     ecx, r8d
    jmp     .down

.done_down:
    pop     r9
    pop     r8
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rbp
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
