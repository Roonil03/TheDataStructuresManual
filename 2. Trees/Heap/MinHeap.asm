; Array-backed heap insertion and repeated root extraction.
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    fmt_out  db "%d ", 0
    fmt_nl   db 10,0

section .bss
    n         resd 1
    heap      resd 400
    heap_size resd 1

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
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rdi, [n]
    call tree_read_int
    cmp eax, 1
    jne input_error
    cmp dword [n], 0
    jl input_error
    cmp dword [n], 400
    jg input_error

    mov dword [heap_size], 0

    xor r12, r12
.read_loop:
    cmp r12d, [n]
    jge .extract_phase

    lea rdi, [rbp-4]
    call tree_read_int
    cmp eax, 1
    jne input_error

    mov eax, [rbp-4]
    call insert_heap

    inc r12
    jmp .read_loop

.extract_phase:

    xor r12, r12
.print_loop:
    cmp r12d, [n]
    jge .done

    call extract_min

    lea rdi, [fmt_out]
    mov esi, eax
    xor eax, eax
    call printf

    inc r12
    jmp .print_loop

.done:
    lea rdi, [fmt_nl]
    xor eax, eax
    call printf

    xor eax, eax
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
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx

    mov ebx, [heap_size]
    mov [heap + 4*rbx], eax
    inc dword [heap_size]

    mov ecx, ebx
.bubble_up:
    test ecx, ecx
    jz .insert_done

    mov edx, ecx
    dec edx
    shr edx, 1

    mov eax, [heap + 4*rcx]
    mov ebx, [heap + 4*rdx]
    cmp eax, ebx
    jge .insert_done

    mov [heap + 4*rcx], ebx
    mov [heap + 4*rdx], eax
    mov ecx, edx
    jmp .bubble_up

.insert_done:
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret

extract_min:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    push r8
    push r9

    mov eax, [heap]

    mov ebx, [heap_size]
    dec ebx
    mov ecx, [heap + 4*rbx]
    mov [heap], ecx
    dec dword [heap_size]

    cmp dword [heap_size], 0
    je .extract_done

    xor ecx, ecx
.bubble_down:

    mov edx, ecx
    shl edx, 1
    inc edx

    cmp edx, [heap_size]
    jge .extract_done

    mov r8d, edx
    mov r9d, [heap + 4*rdx]

    inc edx
    cmp edx, [heap_size]
    jge .compare_parent

    mov ebx, [heap + 4*rdx]
    cmp ebx, r9d
    jge .compare_parent
    mov r8d, edx
    mov r9d, ebx

.compare_parent:

    mov ebx, [heap + 4*rcx]
    cmp ebx, r9d
    jle .extract_done

    mov [heap + 4*rcx], r9d
    mov [heap + 4*r8], ebx
    mov ecx, r8d
    jmp .bubble_down

.extract_done:
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rbp
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
