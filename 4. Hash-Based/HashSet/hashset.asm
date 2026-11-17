; Each bucket holds a chain of nodes allocated from a fixed arena.
section .data

    msg_created:    db "HashSet created with capacity: ", 0
    msg_added:      db "Added: ", 0
    msg_removed:    db "Removed: ", 0
    msg_contains:   db "Contains: ", 0
    msg_size:       db "Size: ", 0
    msg_empty:      db "HashSet is empty", 10, 0
    msg_bucket:     db "Bucket ", 0
    msg_arrow:      db " -> ", 0
    msg_newline:    db 10, 0
    msg_yes:        db "Yes", 10, 0
    msg_no:         db "No", 10, 0
    msg_minus:      db "-"
    msg_space:      db " ", 0
    msg_colon:      db ": ", 0
    msg_true:       db "true", 10, 0
    msg_false:      db "false", 10, 0

    DEFAULT_CAPACITY equ 16

    HEAP_SIZE equ 65536
    NODE_SIZE equ 16
    HASHSET_SIZE equ 24

section .bss
    hashset:        resq 1
    temp_buffer:    resb 64
    heap_memory:    resb 65536
    heap_ptr:       resq 1
    heap_end:       resq 1

section .text
    global _start

_start:

    call init_heap

    mov rdi, DEFAULT_CAPACITY
    call create_hashset
    mov [hashset], rax

    mov rdi, [hashset]
    mov rsi, 10
    call add

    mov rdi, [hashset]
    mov rsi, 20
    call add

    mov rdi, [hashset]
    mov rsi, 15
    call add

    mov rdi, [hashset]
    mov rsi, 25
    call add

    mov rdi, [hashset]
    mov rsi, 10
    call add

    mov rdi, [hashset]
    call display

    mov rdi, [hashset]
    mov rsi, 15
    call contains

    mov rdi, [hashset]
    mov rsi, 100
    call contains

    mov rdi, [hashset]
    call get_size

    mov rdi, [hashset]
    mov rsi, 20
    call remove_element

    mov rdi, [hashset]
    call display

    mov rax, 60
    xor rdi, rdi
    syscall

init_heap:
    push rbp
    mov rbp, rsp

    lea rax, [heap_memory]
    mov [heap_ptr], rax

    add rax, HEAP_SIZE
    mov [heap_end], rax

    pop rbp
    ret

malloc_simple:
    push rbp
    mov rbp, rsp
    push rbx

    mov rbx, [heap_ptr]
    mov rax, rbx
    add rbx, rdi
    jc .error

    cmp rbx, [heap_end]
    ja .error

    mov [heap_ptr], rbx

    push rdi
    push rax
    mov rcx, rdi
    mov rdi, rax
    xor al, al
    rep stosb
    pop rax
    pop rdi

    jmp .done

.error:
    xor rax, rax

.done:
    pop rbx
    pop rbp
    ret

free_simple:
    push rbp
    mov rbp, rsp

    pop rbp
    ret

create_hashset:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    test rdi, rdi
    jle .error
    cmp rdi, (HEAP_SIZE - HASHSET_SIZE) / 8
    ja .error
    mov r12, rdi

    mov rdi, HASHSET_SIZE
    call malloc_simple
    test rax, rax
    jz .error

    mov rbx, rax

    mov rdi, r12
    shl rdi, 3
    call malloc_simple
    test rax, rax
    jz .rollback

    mov [rbx], rax
    mov [rbx + 8], r12
    mov qword [rbx + 16], 0

    mov rax, rbx
    jmp .done

.rollback:
    mov [heap_ptr], rbx
.error:
    xor rax, rax

.done:
    pop r12
    pop rbx
    pop rbp
    ret

hash_function:
    push rbp
    mov rbp, rsp

    mov rax, rdi
    cqo
    xor rax, rdx
    sub rax, rdx

    xor rdx, rdx
    div rsi
    mov rax, rdx

    pop rbp
    ret

add:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi
    mov r12, rsi

    mov rdi, rbx
    mov rsi, r12
    call contains
    test rax, rax
    jnz .already_exists

    mov rdi, r12
    mov rsi, [rbx + 8]
    call hash_function
    mov r13, rax

    mov rdi, NODE_SIZE
    call malloc_simple
    test rax, rax
    jz .error

    mov r14, rax
    mov [r14], r12

    mov rax, [rbx]
    shl r13, 3
    add rax, r13

    mov rcx, [rax]
    mov [r14 + 8], rcx
    mov [rax], r14

    inc qword [rbx + 16]

    mov rax, 1
    jmp .done

.already_exists:
    xor rax, rax
    jmp .done

.error:
    xor rax, rax

.done:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

contains:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    mov rbx, rdi
    mov r12, rsi

    mov rdi, r12
    mov rsi, [rbx + 8]
    call hash_function
    mov r13, rax

    mov rax, [rbx]
    shl r13, 3
    add rax, r13
    mov rax, [rax]

.search_loop:
    test rax, rax
    jz .not_found

    cmp [rax], r12
    je .found

    mov rax, [rax + 8]
    jmp .search_loop

.found:
    mov rax, 1
    jmp .done

.not_found:
    xor rax, rax

.done:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

remove_element:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi
    mov r12, rsi

    mov rdi, r12
    mov rsi, [rbx + 8]
    call hash_function
    mov r13, rax

    mov r14, [rbx]
    shl r13, 3
    add r14, r13

    mov rax, [r14]
    xor rcx, rcx

.search_loop:
    test rax, rax
    jz .not_found

    cmp [rax], r12
    je .found

    mov rcx, rax
    mov rax, [rax + 8]
    jmp .search_loop

.found:

    test rcx, rcx
    jz .remove_head

    mov rdx, [rax + 8]
    mov [rcx + 8], rdx
    jmp .free_node

.remove_head:
    mov rdx, [rax + 8]
    mov [r14], rdx

.free_node:
    mov rdi, rax
    call free_simple

    dec qword [rbx + 16]

    mov rax, 1
    jmp .done

.not_found:
    xor rax, rax

.done:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

get_size:
    push rbp
    mov rbp, rsp

    mov rax, [rdi + 16]

    pop rbp
    ret

display:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi

    cmp qword [rbx + 16], 0
    je .empty

    xor r12, r12
    mov r13, [rbx + 8]

.bucket_loop:
    cmp r12, r13
    jge .done

    mov rax, [rbx]
    mov r14, r12
    shl r14, 3
    add rax, r14
    mov r14, [rax]

    test r14, r14
    jz .next_bucket

    mov rdi, r12
    call print_number

    mov rdi, msg_colon
    call print_string

.node_loop:
    test r14, r14
    jz .bucket_end

    mov rdi, [r14]
    call print_number

    mov rdi, msg_space
    call print_string

    mov r14, [r14 + 8]
    jmp .node_loop

.bucket_end:
    mov rdi, msg_newline
    call print_string

.next_bucket:
    inc r12
    jmp .bucket_loop

.empty:
    mov rdi, msg_empty
    call print_string

.done:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

clear:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi

    xor r12, r12
    mov r13, [rbx + 8]

.bucket_loop:
    cmp r12, r13
    jge .done

    mov rax, [rbx]
    mov r14, r12
    shl r14, 3
    add rax, r14
    mov r14, [rax]

.node_loop:
    test r14, r14
    jz .next_bucket

    mov rcx, [r14 + 8]
    mov rdi, r14
    call free_simple
    mov r14, rcx
    jmp .node_loop

.next_bucket:

    mov rax, [rbx]
    mov r14, r12
    shl r14, 3
    add rax, r14
    mov qword [rax], 0

    inc r12
    jmp .bucket_loop

.done:
    mov qword [rbx + 16], 0

    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

destroy:
    push rbp
    mov rbp, rsp
    push rbx

    mov rbx, rdi

    mov rdi, rbx
    call clear

    mov rdi, [rbx]
    call free_simple

    mov rdi, rbx
    call free_simple

    pop rbx
    pop rbp
    ret

print_number:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov rax, rdi
    lea rbx, [temp_buffer + 63]
    mov byte [rbx], 0
    dec rbx

    mov r12, 10

    test rax, rax
    jns .convert

    neg rax
    push rax
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_minus
    mov rdx, 1
    syscall
    pop rax

.convert:
    xor rdx, rdx
    div r12
    add dl, '0'
    mov [rbx], dl
    dec rbx
    test rax, rax
    jnz .convert

    inc rbx
    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    lea rdx, [temp_buffer + 63]
    sub rdx, rbx
    syscall

    pop r12
    pop rbx
    pop rbp
    ret

print_string:
    push rbp
    mov rbp, rsp
    push rbx

    mov rbx, rdi
    xor rcx, rcx

.strlen:
    cmp byte [rbx + rcx], 0
    je .print
    inc rcx
    jmp .strlen

.print:
    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, rcx
    syscall

    pop rbx
    pop rbp
    ret
