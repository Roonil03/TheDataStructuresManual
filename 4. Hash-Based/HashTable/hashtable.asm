%define TABLE_SIZE 16
%define ENTRY_SIZE 16
%define KEY_SIZE 8
%define VALUE_SIZE 8
%define EMPTY_KEY 0xFFFFFFFFFFFFFFFF
%define DELETED_KEY 0xFFFFFFFFFFFFFFFE

global _start

section .data

    hash_table: times (TABLE_SIZE * ENTRY_SIZE) db 0

    msg_init: db "Hash Table initialized", 0xA
    msg_init_len: equ $ - msg_init

    msg_insert: db "Inserted: key="
    msg_insert_len: equ $ - msg_insert

    msg_search: db "Search: key="
    msg_search_len: equ $ - msg_search

    msg_found: db " Found! value="
    msg_found_len: equ $ - msg_found

    msg_not_found: db " NOT FOUND", 0xA
    msg_not_found_len: equ $ - msg_not_found

    msg_newline: db 0xA
    msg_newline_len: equ 1

    msg_full: db "Hash table is full!", 0xA
    msg_full_len: equ $ - msg_full

    test_keys: dq 42, 15, 97, 3, 88, 120
    test_values: dq 100, 200, 300, 400, 500, 600
    test_count: equ 6

section .bss
    num_buffer: resb 32

section .text

hash_function:
    push rdx
    push rcx

    xor rdx, rdx
    mov rcx, TABLE_SIZE
    div rcx
    mov rax, rdx

    pop rcx
    pop rdx
    ret

init_table:
    push rax
    push rbx
    push rcx

    xor rax, rax
    mov rcx, TABLE_SIZE

.init_loop:
    cmp rax, rcx
    jge .init_done

    mov rbx, rax
    imul rbx, ENTRY_SIZE

    mov qword [hash_table + rbx], EMPTY_KEY

    mov qword [hash_table + rbx + KEY_SIZE], 0

    inc rax
    jmp .init_loop

.init_done:
    pop rcx
    pop rbx
    pop rax
    ret

insert:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    cmp rax, DELETED_KEY
    jae .insert_full
    xor r9d, r9d
    mov rdi, rax
    mov rsi, rbx

    call hash_function
    mov rcx, rax
    xor r8, r8

.insert_probe:

    cmp r8, TABLE_SIZE
    jge .use_available

    mov rax, rcx
    imul rax, ENTRY_SIZE
    lea rbx, [hash_table]
    add rbx, rax

    mov rdx, qword [rbx]
    cmp rdx, rdi
    je .insert_store
    cmp rdx, DELETED_KEY
    jb .occupied
    test r9, r9
    cmovz r9, rbx
    cmp rdx, EMPTY_KEY
    je .use_available
.occupied:

    inc rcx
    cmp rcx, TABLE_SIZE
    jl .insert_continue
    xor rcx, rcx

.insert_continue:
    inc r8
    jmp .insert_probe

.use_available:
    test r9, r9
    jz .insert_full
    mov rbx, r9
.insert_store:

    mov qword [rbx], rdi
    mov qword [rbx + KEY_SIZE], rsi

    xor rax, rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

.insert_full:
    mov rax, 1
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

search:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    cmp rax, DELETED_KEY
    jae .search_not_found
    mov rdi, rax
    call hash_function
    mov rcx, rax
    xor r8, r8

.search_probe:

    cmp r8, TABLE_SIZE
    jge .search_not_found

    mov rax, rcx
    imul rax, ENTRY_SIZE
    lea rbx, [hash_table]
    add rbx, rax

    mov rdx, qword [rbx]

    cmp rdx, EMPTY_KEY
    je .search_not_found

    cmp rdx, rdi
    je .search_found

    inc rcx
    cmp rcx, TABLE_SIZE
    jl .search_next
    xor rcx, rcx

.search_next:
    inc r8
    jmp .search_probe

.search_found:

    mov rax, qword [rbx + KEY_SIZE]
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

.search_not_found:
    mov rax, -1
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

delete:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    cmp rax, DELETED_KEY
    jae .delete_not_found
    mov rdi, rax
    call hash_function
    mov rcx, rax
    xor r8, r8

.delete_probe:
    cmp r8, TABLE_SIZE
    jge .delete_not_found

    mov rax, rcx
    imul rax, ENTRY_SIZE
    lea rbx, [hash_table]
    add rbx, rax

    mov rdx, qword [rbx]

    cmp rdx, EMPTY_KEY
    je .delete_not_found

    cmp rdx, rdi
    je .delete_mark

    inc rcx
    cmp rcx, TABLE_SIZE
    jl .delete_continue
    xor rcx, rcx

.delete_continue:
    inc r8
    jmp .delete_probe

.delete_mark:
    mov qword [rbx], DELETED_KEY
    xor rax, rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

.delete_not_found:
    mov rax, 1
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

print_int:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rcx, num_buffer
    add rcx, 31
    mov byte [rcx], 0
    dec rcx

    mov rbx, rax
    mov rax, rbx

    test rax, rax
    jnz .convert_loop

    mov byte [rcx], '0'
    dec rcx
    jmp .print_it

.convert_loop:
    test rax, rax
    jz .print_it

    xor rdx, rdx
    mov rbx, 10
    div rbx

    add dl, '0'
    mov byte [rcx], dl
    dec rcx

    jmp .convert_loop

.print_it:
    inc rcx
    mov rsi, rcx

    mov rax, num_buffer
    add rax, 31
    sub rax, rcx
    mov rdx, rax

    mov rax, 1
    mov rdi, 1
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

write_string:
    push rax
    push rdi

    mov rax, 1
    mov rdi, 1
    syscall

    pop rdi
    pop rax
    ret

_start:

    call init_table

    mov rsi, msg_init
    mov rdx, msg_init_len
    call write_string

    xor rcx, rcx

.test_insert_loop:
    cmp rcx, test_count
    jge .test_search

    mov rax, [test_keys + rcx * 8]
    mov rbx, [test_values + rcx * 8]

    push rcx

    call insert

    pop rcx

    push rcx
    mov rsi, msg_insert
    mov rdx, msg_insert_len
    call write_string
    pop rcx

    push rcx
    mov rax, [test_keys + rcx * 8]
    call print_int
    pop rcx

    push rcx
    mov rsi, msg_newline
    mov rdx, msg_newline_len
    call write_string
    pop rcx

    inc rcx
    jmp .test_insert_loop

.test_search:

    xor rcx, rcx

.test_search_loop:
    cmp rcx, test_count
    jge .exit

    mov rax, [test_keys + rcx * 8]

    push rcx
    call search
    mov r15, rax
    pop rcx

    push rcx
    mov rsi, msg_search
    mov rdx, msg_search_len
    call write_string
    pop rcx

    push rcx
    mov rax, [test_keys + rcx * 8]
    call print_int
    pop rcx

    cmp r15, -1
    je .not_found

    push rcx
    mov rsi, msg_found
    mov rdx, msg_found_len
    call write_string
    pop rcx

    push rcx
    mov rax, r15
    call print_int
    pop rcx

    jmp .search_next

.not_found:
    push rcx
    mov rsi, msg_not_found
    mov rdx, msg_not_found_len
    call write_string
    pop rcx

.search_next:
    push rcx
    mov rsi, msg_newline
    mov rdx, msg_newline_len
    call write_string
    pop rcx

    inc rcx
    jmp .test_search_loop

.exit:

    mov rax, 60
    xor rdi, rdi
    syscall
