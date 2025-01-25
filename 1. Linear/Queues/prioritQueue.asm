section .data
    prompt_menu db "1. Add node", 10, "2. Remove highest priority node", 10, "3. Display queue", 10, "4. Exit", 10, "Choose option: ", 0
    prompt_value db "Enter a value (0-9): ", 0
    prompt_priority db "Enter priority (0-9): ", 0
    msg_queue db "Priority Queue: ", 0
    space db " -> ", 0
    newline db 10, 0
    empty_msg db "Queue is empty!", 10, 0

section .bss
    head resq 1          ; Pointer to first node
    input_buf resb 2     ; Buffer for user input

section .text
    global _start

_start:
    mov qword [head], 0      ; Initialize head pointer to NULL

main_loop:
    ; Display menu
    mov rsi, prompt_menu
    call print_string

    ; Get user choice
    call read_input
    movzx rax, byte [input_buf]
    sub rax, '0'

    ; Menu handling
    cmp rax, 1
    je add_node
    cmp rax, 2
    je remove_node
    cmp rax, 3
    je display_queue
    cmp rax, 4
    je exit_program
    jmp main_loop

add_node:
    call prompt_and_read_value
    call prompt_and_read_priority
    ; Allocate memory for new node (18 bytes)
    mov rax, 9                     ; sys_mmap
    mov rdi, 0                     ; let kernel choose address
    mov rsi, 18                    ; size (18 bytes)
    mov rdx, 3                     ; PROT_READ | PROT_WRITE
    mov r10, 34                    ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1                     ; fd (no file)
    mov r9, 0                      ; offset
    syscall

    ; Check if memory allocation failed
    cmp rax, -1
    je memory_allocation_failed

    ; Store value and priority in node
    mov byte [rax], r12b           ; Store value
    mov byte [rax + 1], r13b       ; Store priority

    ; If queue is empty, initialize head
    cmp qword [head], 0
    je initialize_queue

    ; Insert node based on priority
    mov rbx, [head]
    mov rcx, 0
find_position:
    cmp byte [rbx + 1], r13b       ; Compare current node priority with new node priority
    jg insert_before
    mov rcx, rbx                   ; Save previous node
    mov rbx, [rbx + 2]             ; Move to next node
    cmp rbx, 0                     ; Check if end of list
    je insert_at_end
    jmp find_position

insert_before:
    mov qword [rax + 2], rbx       ; New node's next points to current node
    cmp rcx, 0
    je set_new_head
    mov qword [rcx + 2], rax       ; Previous node's next points to new node
    jmp main_loop

insert_at_end:
    mov qword [rcx + 2], rax       ; Last node's next points to new node
    mov qword [rax + 2], 0         ; New node's next points to NULL
    jmp main_loop

set_new_head:
    mov qword [head], rax          ; Set new head to new node
    jmp main_loop

initialize_queue:
    mov qword [head], rax          ; Set head to new node
    mov qword [rax + 2], 0         ; Next points to NULL
    jmp main_loop

remove_node:
    ; Check if queue is empty
    cmp qword [head], 0
    je print_empty

    ; Remove node from front (highest priority)
    mov rbx, [head]
    mov rcx, [rbx + 2]             ; Next node
    mov qword [head], rcx          ; Update head to next node

    ; Free the removed node's memory (optional)
    ; mov rdi, rbx
    ; mov rsi, 18
    ; mov rax, 11                    ; sys_munmap
    ; syscall

    jmp main_loop

display_queue:
    ; Print "Priority Queue: "
    mov rsi, msg_queue
    call print_string

    ; Check if queue is empty
    cmp qword [head], 0
    je print_empty

    mov rbx, [head]                ; Start from head
print_loop:
    ; Print value and priority
    movzx rax, byte [rbx]          ; Get value
    add rax, '0'                   ; Convert to ASCII
    push rax
    mov rsi, rsp
    mov rdx, 1
    call print_chars
    pop rax

    movzx rax, byte [rbx + 1]      ; Get priority
    add rax, '0'                   ; Convert to ASCII
    push rax
    mov rsi, rsp
    mov rdx, 1
    call print_chars
    pop rax

    mov rbx, [rbx + 2]             ; Move to next node
    
    ; Print arrow if not at the end
    cmp rbx, 0
    je print_newline
    mov rsi, space
    call print_string
    jmp print_loop

print_empty:
    mov rsi, empty_msg
    call print_string
    jmp main_loop

print_newline:
    mov rsi, newline
    call print_string
    jmp main_loop

exit_program:
    mov rax, 60                    ; sys_exit
    xor rdi, rdi                   ; return 0
    syscall

prompt_and_read_value:
    ; Prompt for value
    mov rsi, prompt_value
    call print_string
    
    ; Read value
    call read_input
    movzx r12, byte [input_buf]    ; Store input value
    sub r12, '0'                   ; Convert to integer
    ret

prompt_and_read_priority:
    ; Prompt for priority
    mov rsi, prompt_priority
    call print_string
    
    ; Read priority
    call read_input
    movzx r13, byte [input_buf]    ; Store input priority
    sub r13, '0'                   ; Convert to integer
    ret

; Helper functions
print_string:
    ; Calculate string length
    push rsi
    xor rdx, rdx
count_loop:
    cmp byte [rsi + rdx], 0
    je count_done
    inc rdx
    jmp count_loop
count_done:
    pop rsi
print_chars:
    mov rax, 1                      ; sys_write
    mov rdi, 1                      ; stdout
    syscall
    ret

read_input:
    mov rax, 0                      ; sys_read
    mov rdi, 0                      ; stdin
    mov rsi, input_buf
    mov rdx, 2                      ; read 2 bytes (char + newline)
    syscall
    ret

memory_allocation_failed:
    ; Handle memory allocation failure
    mov rsi, empty_msg
    call print_string
    jmp main_loop