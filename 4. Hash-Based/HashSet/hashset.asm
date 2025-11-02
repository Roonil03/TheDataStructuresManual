section .data
    ; Messages
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
    msg_space:      db " ", 0
    msg_colon:      db ": ", 0
    msg_true:       db "true", 10, 0
    msg_false:      db "false", 10, 0
    
    DEFAULT_CAPACITY equ 16
    
    ; Memory management constants
    HEAP_SIZE equ 65536         ; 64KB heap
    NODE_SIZE equ 16            ; Size of each node
    HASHSET_SIZE equ 24         ; Size of HashSet structure

section .bss
    hashset:        resq 1      ; Pointer to HashSet structure
    temp_buffer:    resb 64     ; Temporary buffer for number conversions
    heap_memory:    resb 65536  ; Static heap memory
    heap_ptr:       resq 1      ; Current heap pointer
    heap_end:       resq 1      ; End of heap

section .text
    global _start

; ============================================================================
; HashSet Structure Layout:
;   Offset 0:  buckets pointer (8 bytes)
;   Offset 8:  capacity (8 bytes)
;   Offset 16: size (8 bytes)
;   Total: 24 bytes
;
; Node Structure Layout:
;   Offset 0:  value (8 bytes)
;   Offset 8:  next pointer (8 bytes)
;   Total: 16 bytes
; ============================================================================

_start:
    ; Initialize heap
    call init_heap
    
    ; Create HashSet
    mov rdi, DEFAULT_CAPACITY
    call create_hashset
    mov [hashset], rax

    ; Test operations
    ; Add elements
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
    mov rsi, 10  ; Duplicate, should not be added
    call add

    ; Display HashSet
    mov rdi, [hashset]
    call display

    ; Check if elements exist
    mov rdi, [hashset]
    mov rsi, 15
    call contains
    ; Result in rax (1 if found, 0 if not)

    mov rdi, [hashset]
    mov rsi, 100
    call contains

    ; Print size
    mov rdi, [hashset]
    call get_size
    ; Size in rax

    ; Remove element
    mov rdi, [hashset]
    mov rsi, 20
    call remove_element

    ; Display after removal
    mov rdi, [hashset]
    call display

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; ============================================================================
; init_heap: Initialize the simple heap allocator
; ============================================================================
init_heap:
    push rbp
    mov rbp, rsp
    
    lea rax, [heap_memory]
    mov [heap_ptr], rax
    
    add rax, HEAP_SIZE
    mov [heap_end], rax
    
    pop rbp
    ret

; ============================================================================
; malloc_simple: Simple memory allocator
; Input: rdi = size to allocate
; Output: rax = pointer to allocated memory, or 0 on failure
; ============================================================================
malloc_simple:
    push rbp
    mov rbp, rsp
    push rbx
    
    mov rbx, [heap_ptr]     ; Current heap pointer
    mov rax, rbx
    add rbx, rdi            ; New heap pointer
    
    ; Check if we have enough space
    cmp rbx, [heap_end]
    jg .error
    
    ; Update heap pointer
    mov [heap_ptr], rbx
    
    ; Zero out the allocated memory
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

; ============================================================================
; free_simple: Simple memory free (no-op for this implementation)
; Input: rdi = pointer to free
; Note: This implementation uses a simple bump allocator, so free is a no-op
; ============================================================================
free_simple:
    push rbp
    mov rbp, rsp
    ; No-op for simple allocator
    pop rbp
    ret

; ============================================================================
; create_hashset: Create and initialize a new HashSet
; Input: rdi = capacity (number of buckets)
; Output: rax = pointer to HashSet structure, or 0 on failure
; ============================================================================
create_hashset:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    mov r12, rdi            ; Save capacity
    
    ; Allocate HashSet structure (24 bytes)
    mov rdi, HASHSET_SIZE
    call malloc_simple
    test rax, rax
    jz .error
    
    mov rbx, rax            ; Save HashSet pointer
    
    ; Allocate buckets array (capacity * 8 bytes)
    mov rdi, r12
    shl rdi, 3              ; Multiply by 8
    call malloc_simple
    test rax, rax
    jz .error
    
    ; Initialize HashSet structure
    mov [rbx], rax          ; buckets pointer
    mov [rbx + 8], r12      ; capacity
    mov qword [rbx + 16], 0 ; size = 0
    
    ; Initialize all buckets to NULL
    mov rcx, r12
    mov rdi, [rbx]
.init_buckets:
    mov qword [rdi], 0
    add rdi, 8
    loop .init_buckets
    
    mov rax, rbx            ; Return HashSet pointer
    jmp .done
    
.error:
    xor rax, rax            ; Return NULL on error
    
.done:
    pop r12
    pop rbx
    pop rbp
    ret

; ============================================================================
; hash_function: Calculate hash value for a given key
; Input: rdi = value to hash, rsi = capacity
; Output: rax = hash value (bucket index)
; ============================================================================
hash_function:
    push rbp
    mov rbp, rsp
    
    ; Simple hash: abs(value) % capacity
    mov rax, rdi
    cqo                     ; Sign extend rax to rdx:rax
    xor rax, rdx            ; Take absolute value
    sub rax, rdx
    
    xor rdx, rdx
    div rsi                 ; rax = value / capacity, rdx = value % capacity
    mov rax, rdx            ; Return remainder
    
    pop rbp
    ret

; ============================================================================
; add: Add an element to the HashSet
; Input: rdi = HashSet pointer, rsi = value to add
; Output: rax = 1 if added, 0 if already exists
; ============================================================================
add:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    
    mov rbx, rdi            ; HashSet pointer
    mov r12, rsi            ; Value to add
    
    ; Check if value already exists
    mov rdi, rbx
    mov rsi, r12
    call contains
    test rax, rax
    jnz .already_exists
    
    ; Calculate hash
    mov rdi, r12
    mov rsi, [rbx + 8]      ; capacity
    call hash_function
    mov r13, rax            ; Save hash index
    
    ; Allocate new node
    mov rdi, NODE_SIZE
    call malloc_simple
    test rax, rax
    jz .error
    
    mov r14, rax            ; New node pointer
    mov [r14], r12          ; Store value
    
    ; Insert at beginning of bucket
    mov rax, [rbx]          ; buckets array
    shl r13, 3              ; index * 8
    add rax, r13            ; &buckets[index]
    
    mov rcx, [rax]          ; Old head
    mov [r14 + 8], rcx      ; new_node->next = old_head
    mov [rax], r14          ; buckets[index] = new_node
    
    ; Increment size
    inc qword [rbx + 16]
    
    mov rax, 1              ; Success
    jmp .done
    
.already_exists:
    xor rax, rax            ; Already exists
    jmp .done
    
.error:
    xor rax, rax            ; Error
    
.done:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ============================================================================
; contains: Check if an element exists in the HashSet
; Input: rdi = HashSet pointer, rsi = value to check
; Output: rax = 1 if exists, 0 if not
; ============================================================================
contains:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    mov rbx, rdi            ; HashSet pointer
    mov r12, rsi            ; Value to check
    
    ; Calculate hash
    mov rdi, r12
    mov rsi, [rbx + 8]      ; capacity
    call hash_function
    mov r13, rax            ; hash index
    
    ; Get bucket head
    mov rax, [rbx]          ; buckets array
    shl r13, 3              ; index * 8
    add rax, r13
    mov rax, [rax]          ; buckets[index]
    
    ; Search in bucket
.search_loop:
    test rax, rax
    jz .not_found
    
    cmp [rax], r12          ; Compare node value
    je .found
    
    mov rax, [rax + 8]      ; next node
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

; ============================================================================
; remove_element: Remove an element from the HashSet
; Input: rdi = HashSet pointer, rsi = value to remove
; Output: rax = 1 if removed, 0 if not found
; ============================================================================
remove_element:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    
    mov rbx, rdi            ; HashSet pointer
    mov r12, rsi            ; Value to remove
    
    ; Calculate hash
    mov rdi, r12
    mov rsi, [rbx + 8]      ; capacity
    call hash_function
    mov r13, rax            ; hash index
    
    ; Get bucket head pointer
    mov r14, [rbx]          ; buckets array
    shl r13, 3
    add r14, r13            ; &buckets[index]
    
    mov rax, [r14]          ; Current node
    xor rcx, rcx            ; Previous node = NULL
    
.search_loop:
    test rax, rax
    jz .not_found
    
    cmp [rax], r12
    je .found
    
    mov rcx, rax            ; prev = current
    mov rax, [rax + 8]      ; current = current->next
    jmp .search_loop
    
.found:
    ; Remove node
    test rcx, rcx
    jz .remove_head
    
    ; Remove from middle/end
    mov rdx, [rax + 8]      ; next
    mov [rcx + 8], rdx      ; prev->next = current->next
    jmp .free_node
    
.remove_head:
    mov rdx, [rax + 8]      ; next
    mov [r14], rdx          ; buckets[index] = next
    
.free_node:
    mov rdi, rax
    call free_simple
    
    ; Decrement size
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

; ============================================================================
; get_size: Get the number of elements in the HashSet
; Input: rdi = HashSet pointer
; Output: rax = size
; ============================================================================
get_size:
    push rbp
    mov rbp, rsp
    
    mov rax, [rdi + 16]     ; Return size
    
    pop rbp
    ret

; ============================================================================
; display: Display all elements in the HashSet
; Input: rdi = HashSet pointer
; ============================================================================
display:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    
    mov rbx, rdi            ; HashSet pointer
    
    ; Check if empty
    cmp qword [rbx + 16], 0
    je .empty
    
    ; Print each bucket
    xor r12, r12            ; bucket index = 0
    mov r13, [rbx + 8]      ; capacity
    
.bucket_loop:
    cmp r12, r13
    jge .done
    
    ; Get bucket head
    mov rax, [rbx]          ; buckets array
    mov r14, r12
    shl r14, 3
    add rax, r14
    mov r14, [rax]          ; bucket head
    
    ; Skip empty buckets
    test r14, r14
    jz .next_bucket
    
    ; Print bucket index
    mov rdi, r12
    call print_number
    
    mov rdi, msg_colon
    call print_string
    
    ; Print nodes in bucket
.node_loop:
    test r14, r14
    jz .bucket_end
    
    mov rdi, [r14]          ; node value
    call print_number
    
    mov rdi, msg_space
    call print_string
    
    mov r14, [r14 + 8]      ; next node
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

; ============================================================================
; clear: Remove all elements from the HashSet
; Input: rdi = HashSet pointer
; ============================================================================
clear:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    
    mov rbx, rdi            ; HashSet pointer
    
    xor r12, r12            ; bucket index = 0
    mov r13, [rbx + 8]      ; capacity
    
.bucket_loop:
    cmp r12, r13
    jge .done
    
    ; Get bucket head
    mov rax, [rbx]
    mov r14, r12
    shl r14, 3
    add rax, r14
    mov r14, [rax]          ; bucket head
    
    ; Clear this bucket
.node_loop:
    test r14, r14
    jz .next_bucket
    
    mov rcx, [r14 + 8]      ; Save next
    mov rdi, r14
    call free_simple
    mov r14, rcx
    jmp .node_loop
    
.next_bucket:
    ; Set bucket to NULL
    mov rax, [rbx]
    mov r14, r12
    shl r14, 3
    add rax, r14
    mov qword [rax], 0
    
    inc r12
    jmp .bucket_loop
    
.done:
    mov qword [rbx + 16], 0 ; size = 0
    
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ============================================================================
; destroy: Free all memory used by the HashSet
; Input: rdi = HashSet pointer
; ============================================================================
destroy:
    push rbp
    mov rbp, rsp
    push rbx
    
    mov rbx, rdi            ; HashSet pointer
    
    ; Clear all elements
    mov rdi, rbx
    call clear
    
    ; Free buckets array
    mov rdi, [rbx]
    call free_simple
    
    ; Free HashSet structure
    mov rdi, rbx
    call free_simple
    
    pop rbx
    pop rbp
    ret

; ============================================================================
; Helper function: print_number
; Input: rdi = number to print
; ============================================================================
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
    mov rsi, msg_space
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

; ============================================================================
; Helper function: print_string
; Input: rdi = pointer to null-terminated string
; ============================================================================
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