; Linked List implementation in NASM (64-bit)
; Each node contains: value (1 byte) and next pointer (8 bytes)

section .data
    prompt_menu db "1. Add node", 10, "2. Display list", 10, "3. Exit", 10, "Choose option: ", 0
    prompt_value db "Enter a value (0-9): ", 0
    msg_list db "Linked List: ", 0
    space db " -> ", 0
    null_msg db "NULL", 10, 0
    newline db 10, 0

section .bss
    head resq 1          ; Pointer to first node
    input_buf resb 2     ; Buffer for user input
    current resq 1       ; Pointer to current node

section .text
    global _start

; Node structure (9 bytes total):
; - value: 1 byte
; - next:  8 bytes (pointer to next node)

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
    je display_list
    cmp rax, 3
    je exit_program
    jmp main_loop

add_node:
    ; Prompt for value
    mov rsi, prompt_value
    call print_string
    
    ; Read value
    call read_input
    movzx r12, byte [input_buf]    ; Store input value
    sub r12, '0'                   ; Convert to integer

    ; Allocate memory for new node (9 bytes)
    mov rax, 9                     ; sys_mmap
    mov rdi, 0                     ; let kernel choose address
    mov rsi, 9                     ; size (9 bytes)
    mov rdx, 3                     ; PROT_READ | PROT_WRITE
    mov r10, 34                    ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1                     ; fd (no file)
    mov r9, 0                      ; offset
    syscall

    ; Store value in node
    mov byte [rax], r12b          ; Store value
    mov qword [rax + 1], 0        ; Set next pointer to NULL

    ; If list is empty, set head
    cmp qword [head], 0
    je set_head

    ; Find last node
    mov rbx, [head]
find_last:
    cmp qword [rbx + 1], 0        ; Check if next is NULL
    je found_last
    mov rbx, [rbx + 1]            ; Move to next node
    jmp find_last

found_last:
    mov [rbx + 1], rax            ; Set next pointer of last node
    jmp main_loop

set_head:
    mov [head], rax               ; Set head to new node
    jmp main_loop

display_list:
    ; Print "Linked List: "
    mov rsi, msg_list
    call print_string

    ; Start from head
    mov rbx, [head]
    cmp rbx, 0
    je print_null

print_loop:
    ; Print value
    movzx rax, byte [rbx]         ; Get value
    add rax, '0'                  ; Convert to ASCII
    push rax
    mov rsi, rsp
    mov rdx, 1
    call print_chars
    pop rax

    ; Check if next node exists
    cmp qword [rbx + 1], 0
    je print_null

    ; Print arrow
    mov rsi, space
    call print_string

    ; Move to next node
    mov rbx, [rbx + 1]
    jmp print_loop

print_null:
    mov rsi, null_msg
    call print_string
    jmp main_loop

exit_program:
    mov rax, 60                   ; sys_exit
    xor rdi, rdi                  ; return 0
    syscall

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
    mov rax, 1                    ; sys_write
    mov rdi, 1                    ; stdout
    syscall
    ret

read_input:
    mov rax, 0                    ; sys_read
    mov rdi, 0                    ; stdin
    mov rsi, input_buf
    mov rdx, 2                    ; read 2 bytes (char + newline)
    syscall
    ret