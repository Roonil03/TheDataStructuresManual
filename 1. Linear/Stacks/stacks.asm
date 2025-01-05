; Stack implementation using Linked List in NASM x86_64

section .data
    menu db "Stack Operations:", 10
         db "1. Push", 10
         db "2. Pop", 10
         db "3. Peek", 10
         db "4. Exit", 10
         db "Enter choice: ", 0
    
    push_prompt db "Enter value to push (0-9): ", 0
    pop_msg db "Popped value: ", 0
    peek_msg db "Top value: ", 0
    empty_msg db "Stack is empty!", 10, 0
    newline db 10, 0

section .bss
    top resq 1           ; Points to top of stack
    choice resb 2        ; For menu choice
    input_val resb 2     ; For push value
    temp_val resb 1      ; For temporary value storage

section .text
    global _start

_start:
    mov qword [top], 0   ; Initialize top to NULL

main_loop:
    ; Display menu
    mov rsi, menu
    call print_string
    
    ; Get choice
    mov rsi, choice
    call read_input
    mov al, [choice]
    sub al, '0'

    ; Menu handling
    cmp al, 1
    je push_value
    cmp al, 2
    je pop_value
    cmp al, 3
    je peek_value
    cmp al, 4
    je exit_program
    jmp main_loop

push_value:
    ; Prompt for value
    mov rsi, push_prompt
    call print_string
    
    ; Read value
    mov rsi, input_val
    call read_input
    movzx r12, byte [input_val]
    sub r12, '0'

    ; Allocate new node (9 bytes: 1 for data, 8 for next pointer)
    mov rax, 9          ; sys_mmap
    mov rdi, 0          ; let kernel choose address
    mov rsi, 9          ; size
    mov rdx, 3          ; PROT_READ | PROT_WRITE
    mov r10, 34         ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1          ; fd
    mov r9, 0          ; offset
    syscall

    ; Store value and link
    mov byte [rax], r12b        ; Store value
    mov rbx, [top]             ; Get current top
    mov [rax + 1], rbx         ; New node points to current top
    mov [top], rax             ; Update top
    jmp main_loop

pop_value:
    ; Check if stack is empty
    cmp qword [top], 0
    je stack_empty

    ; Print message
    mov rsi, pop_msg
    call print_string

    ; Get value from top node
    mov rbx, [top]
    movzx rax, byte [rbx]
    mov [temp_val], al         ; Store value temporarily
    add byte [temp_val], '0'   ; Convert to ASCII

    ; Print the value
    mov rsi, temp_val
    mov rdx, 1
    call print_chars

    ; Print newline
    mov rsi, newline
    call print_string

    ; Update top
    mov rax, [rbx + 1]        ; Get next node
    mov rcx, [top]            ; Save old top for freeing
    mov [top], rax            ; Update top

    jmp main_loop

peek_value:
    ; Check if stack is empty
    cmp qword [top], 0
    je stack_empty

    ; Print message
    mov rsi, peek_msg
    call print_string

    ; Get value from top node
    mov rbx, [top]
    movzx rax, byte [rbx]
    mov [temp_val], al         ; Store value temporarily
    add byte [temp_val], '0'   ; Convert to ASCII

    ; Print the value
    mov rsi, temp_val
    mov rdx, 1
    call print_chars

    ; Print newline
    mov rsi, newline
    call print_string

    jmp main_loop

stack_empty:
    mov rsi, empty_msg
    call print_string
    jmp main_loop

exit_program:
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; return 0
    syscall

; Helper functions
print_string:
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
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    ret

read_input:
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rdx, 2          ; Read 2 bytes (char + newline)
    syscall
    ret