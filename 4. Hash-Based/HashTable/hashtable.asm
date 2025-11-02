%define TABLE_SIZE 16          ; Size of hash table (must be power of 2)
%define ENTRY_SIZE 16          ; Size per entry (8 bytes key + 8 bytes value)
%define KEY_SIZE 8             ; 64-bit key
%define VALUE_SIZE 8           ; 64-bit value
%define EMPTY_KEY 0xFFFFFFFFFFFFFFFF  ; Mark for empty slots
%define DELETED_KEY 0xFFFFFFFFFFFFFFFE ; Mark for deleted slots

global _start

section .data
    ; Hash table structure
    hash_table: times (TABLE_SIZE * ENTRY_SIZE) db 0
    
    ; Messages for output
    msg_init: db "Hash Table initialized", 0xA
    msg_init_len: equ $ - msg_init
    
    msg_insert: db "Inserted: key=", 0
    msg_insert_len: equ $ - msg_insert
    
    msg_search: db "Search: key=", 0
    msg_search_len: equ $ - msg_search
    
    msg_found: db " Found! value=", 0
    msg_found_len: equ $ - msg_found
    
    msg_not_found: db " NOT FOUND", 0xA
    msg_not_found_len: equ $ - msg_not_found
    
    msg_newline: db 0xA
    msg_newline_len: equ 1
    
    msg_full: db "Hash table is full!", 0xA
    msg_full_len: equ $ - msg_full
    
    ; Test data
    test_keys: dq 42, 15, 97, 3, 88, 120
    test_values: dq 100, 200, 300, 400, 500, 600
    test_count: equ 6

section .bss
    num_buffer: resb 32        ; Buffer for integer to string conversion

section .text

; ================================================================================
; Hash function: Simple modulo hash
; Input: rax = key
; Output: rax = hash value (0 to TABLE_SIZE-1)
; ================================================================================
hash_function:
    push rdx
    push rcx
    
    xor rdx, rdx
    mov rcx, TABLE_SIZE
    div rcx                    ; rax = rax / rcx, rdx = rax % rcx
    mov rax, rdx               ; rax = hash value
    
    pop rcx
    pop rdx
    ret

; ================================================================================
; Initialize hash table - mark all slots as empty
; ================================================================================
init_table:
    push rax
    push rbx
    push rcx
    
    xor rax, rax               ; Counter
    mov rcx, TABLE_SIZE
    
.init_loop:
    cmp rax, rcx
    jge .init_done
    
    ; Calculate address: hash_table + (index * ENTRY_SIZE)
    mov rbx, rax
    imul rbx, ENTRY_SIZE       ; rbx = offset
    
    ; Mark key as empty
    mov qword [hash_table + rbx], EMPTY_KEY
    ; Initialize value to 0
    mov qword [hash_table + rbx + KEY_SIZE], 0
    
    inc rax
    jmp .init_loop
    
.init_done:
    pop rcx
    pop rbx
    pop rax
    ret

; ================================================================================
; Insert key-value pair into hash table
; Input: rax = key, rbx = value
; Output: rax = 0 (success), 1 (failure - table full)
; ================================================================================
insert:
    push rbx                   ; Save value
    push rcx
    push rdx
    push rsi
    push rdi
    
    mov rdi, rax               ; rdi = key to insert
    mov rsi, rbx               ; rsi = value to insert
    
    ; Calculate hash index
    call hash_function
    mov rcx, rax               ; rcx = hash index
    xor r8, r8                 ; r8 = probe count
    
.insert_probe:
    ; Check if we've probed the entire table
    cmp r8, TABLE_SIZE
    jge .insert_full
    
    ; Calculate address: hash_table + (index * ENTRY_SIZE)
    mov rax, rcx
    imul rax, ENTRY_SIZE
    lea rbx, [hash_table]
    add rbx, rax               ; rbx = address of slot
    
    ; Check if slot is empty or deleted
    mov rdx, qword [rbx]
    cmp rdx, EMPTY_KEY
    je .insert_store
    cmp rdx, DELETED_KEY
    je .insert_store
    
    ; Slot occupied, probe next
    inc rcx
    cmp rcx, TABLE_SIZE        ; Wrap around if needed
    jl .insert_continue
    xor rcx, rcx               ; Wrap to beginning
    
.insert_continue:
    inc r8
    jmp .insert_probe
    
.insert_store:
    ; Store key and value at rbx
    mov qword [rbx], rdi              ; Store key
    mov qword [rbx + KEY_SIZE], rsi   ; Store value
    
    xor rax, rax               ; Return success (0)
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
    
.insert_full:
    mov rax, 1                 ; Return failure (1)
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; ================================================================================
; Search for key in hash table
; Input: rax = key to search
; Output: rax = value if found, -1 if not found
; ================================================================================
search:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    mov rdi, rax               ; rdi = search key
    call hash_function
    mov rcx, rax               ; rcx = hash index
    xor r8, r8                 ; r8 = probe count
    
.search_probe:
    ; Check if we've probed the entire table
    cmp r8, TABLE_SIZE
    jge .search_not_found
    
    ; Calculate address
    mov rax, rcx
    imul rax, ENTRY_SIZE
    lea rbx, [hash_table]
    add rbx, rax               ; rbx = address of slot
    
    ; Get key at this position
    mov rdx, qword [rbx]
    
    ; Check if empty (no key found)
    cmp rdx, EMPTY_KEY
    je .search_not_found
    
    ; Check if this is our key
    cmp rdx, rdi
    je .search_found
    
    ; Continue probing
    inc rcx
    cmp rcx, TABLE_SIZE        ; Wrap around if needed
    jl .search_next
    xor rcx, rcx               ; Wrap to beginning
    
.search_next:
    inc r8
    jmp .search_probe
    
.search_found:
    ; Return the value
    mov rax, qword [rbx + KEY_SIZE]
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret
    
.search_not_found:
    mov rax, -1                ; Return -1 for not found
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; ================================================================================
; Delete key from hash table (mark as deleted)
; Input: rax = key to delete
; Output: rax = 0 (success), 1 (not found)
; ================================================================================
delete:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    mov rdi, rax               ; rdi = key to delete
    call hash_function
    mov rcx, rax               ; rcx = hash index
    xor r8, r8                 ; r8 = probe count
    
.delete_probe:
    cmp r8, TABLE_SIZE
    jge .delete_not_found
    
    mov rax, rcx
    imul rax, ENTRY_SIZE
    lea rbx, [hash_table]
    add rbx, rax               ; rbx = address of slot
    
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

; ================================================================================
; Print integer (for testing)
; Input: rax = number to print
; ================================================================================
print_int:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    mov rcx, num_buffer
    add rcx, 31                ; Point to end of buffer
    mov byte [rcx], 0          ; Null terminator
    dec rcx
    
    mov rbx, rax               ; rbx = number
    mov rax, rbx
    
    ; Handle zero special case
    test rax, rax
    jnz .convert_loop
    
    mov byte [rcx], '0'
    jmp .print_it
    
.convert_loop:
    test rax, rax
    jz .print_it
    
    xor rdx, rdx
    mov rbx, 10
    div rbx                    ; rax = rax / 10, rdx = rax % 10
    
    add dl, '0'                ; Convert to ASCII
    mov byte [rcx], dl
    dec rcx
    
    jmp .convert_loop
    
.print_it:
    inc rcx                    ; Move to first digit
    mov rsi, rcx
    
    ; Calculate length
    mov rax, num_buffer
    add rax, 31
    sub rax, rcx
    mov rdx, rax               ; rdx = length
    
    ; Write syscall
    mov rax, 1                 ; sys_write
    mov rdi, 1                 ; stdout
    syscall
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ================================================================================
; Write string to stdout
; Input: rsi = string address, rdx = length
; ================================================================================
write_string:
    push rax
    push rdi
    
    mov rax, 1                 ; syscall: write
    mov rdi, 1                 ; fd: stdout
    syscall
    
    pop rdi
    pop rax
    ret

; ================================================================================
; Main program
; ================================================================================
_start:
    ; Initialize hash table
    call init_table
    
    ; Print initialization message
    mov rsi, msg_init
    mov rdx, msg_init_len
    call write_string
    
    ; Test insertions
    xor rcx, rcx               ; Counter for test data
    
.test_insert_loop:
    cmp rcx, test_count
    jge .test_search
    
    ; Get key and value
    mov rax, [test_keys + rcx * 8]
    mov rbx, [test_values + rcx * 8]
    
    push rcx                   ; Save counter
    
    ; Insert
    call insert
    
    pop rcx                    ; Restore counter
    
    ; Print message
    push rcx
    mov rsi, msg_insert
    mov rdx, msg_insert_len
    call write_string
    pop rcx
    
    ; Print key
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
    ; Test searches
    xor rcx, rcx
    
.test_search_loop:
    cmp rcx, test_count
    jge .exit
    
    ; Search for key
    mov rax, [test_keys + rcx * 8]
    
    push rcx
    call search
    mov r15, rax               ; Save search result in r15
    pop rcx
    
    ; Print message
    push rcx
    mov rsi, msg_search
    mov rdx, msg_search_len
    call write_string
    pop rcx
    
    ; Print key
    push rcx
    mov rax, [test_keys + rcx * 8]
    call print_int
    pop rcx
    
    ; Check if found
    cmp r15, -1
    je .not_found
    
    ; Print found message
    push rcx
    mov rsi, msg_found
    mov rdx, msg_found_len
    call write_string
    pop rcx
    
    ; Print value
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
    ; Exit program
    mov rax, 60                ; syscall: exit
    xor rdi, rdi               ; exit code 0
    syscall
