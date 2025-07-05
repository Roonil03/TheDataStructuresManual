; minheap.asm
BITS 64
default rel

section .note.GNU-stack noalloc noexec nowrite progbits

section .data
    fmt_d    db "%d", 0
    fmt_out  db "%d ", 0
    fmt_nl   db 10,0

section .bss
    n         resd 1
    heap      resd 400      ; Larger array
    heap_size resd 1

section .text
    extern scanf, printf
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Read n
    lea rdi, [fmt_d]
    lea rsi, [n]
    xor eax, eax
    call scanf

    ; Initialize heap_size = 0
    mov dword [heap_size], 0

    ; Read and insert each element
    xor r12, r12              ; i = 0
.read_loop:
    cmp r12d, [n]
    jge .extract_phase

    ; Read value
    lea rdi, [fmt_d]
    lea rsi, [rbp-4]
    xor eax, eax
    call scanf

    mov eax, [rbp-4]
    call insert_heap

    inc r12
    jmp .read_loop

.extract_phase:
    ; Extract and print all elements
    xor r12, r12              ; count = 0
.print_loop:
    cmp r12d, [n]
    jge .done

    call extract_min
    
    ; Print the extracted value
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
    ret

; Insert value into heap
; EAX = value to insert
insert_heap:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    
    ; Place at end of heap
    mov ebx, [heap_size]
    mov [heap + 4*rbx], eax
    inc dword [heap_size]
    
    ; Bubble up
    mov ecx, ebx              ; current position
.bubble_up:
    test ecx, ecx
    jz .insert_done
    
    ; Calculate parent = (i-1)/2
    mov edx, ecx
    dec edx
    shr edx, 1
    
    ; Compare current with parent
    mov eax, [heap + 4*rcx]
    mov ebx, [heap + 4*rdx]
    cmp eax, ebx
    jge .insert_done
    
    ; Swap with parent
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

; Extract minimum value from heap
; Returns: EAX = minimum value
extract_min:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    push r8
    push r9
    
    ; Get minimum (root)
    mov eax, [heap]
    
    ; Move last element to root
    mov ebx, [heap_size]
    dec ebx
    mov ecx, [heap + 4*rbx]
    mov [heap], ecx
    dec dword [heap_size]
    
    ; If heap is now empty, we're done
    cmp dword [heap_size], 0
    je .extract_done
    
    ; Bubble down from root
    xor ecx, ecx              ; current = 0
.bubble_down:
    ; Left child = 2*i + 1
    mov edx, ecx
    shl edx, 1
    inc edx
    
    ; Check if left child exists
    cmp edx, [heap_size]
    jge .extract_done
    
    ; Find smallest child
    mov r8d, edx              ; smallest_idx = left
    mov r9d, [heap + 4*rdx]   ; smallest_val = heap[left]
    
    ; Check right child = 2*i + 2
    inc edx
    cmp edx, [heap_size]
    jge .compare_parent
    
    mov ebx, [heap + 4*rdx]   ; right_val
    cmp ebx, r9d
    jge .compare_parent
    mov r8d, edx              ; smallest_idx = right
    mov r9d, ebx              ; smallest_val = right_val

.compare_parent:
    ; Compare parent with smallest child
    mov ebx, [heap + 4*rcx]   ; parent_val
    cmp ebx, r9d
    jle .extract_done
    
    ; Swap parent with smallest child
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
