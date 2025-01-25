section .data
    prompt_menu db "1. Add node to front", 10, "2. Add node to back", 10, "3. Remove node from front", 10, "4. Remove node from back", 10, "5. Display deque", 10, "6. Exit", 10, "Choose option: ", 0
    prompt_value db "Enter a value (0-9): ", 0
    msg_deque db "Deque: ", 0
    space db " <-> ", 0
    newline db 10, 0
    empty_msg db "Deque is empty!", 10, 0

section .bss
    head resq 1          ; Pointer to first node
    tail resq 1          ; Pointer to last node
    input_buf resb 2     ; Buffer for user input

section .text
    global _start

_start:
    mov qword [head], 0      ; Initialize head pointer to NULL
    mov qword [tail], 0      ; Initialize tail pointer to NULL

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
    je add_node_front
    cmp rax, 2
    je add_node_back
    cmp rax, 3
    je remove_node_front
    cmp rax, 4
    je remove_node_back
    cmp rax, 5
    je display_deque
    cmp rax, 6
    je exit_program
    jmp main_loop

add_node_front:
    call prompt_and_read_value
    ; Allocate memory for new node (17 bytes)
    mov rax, 9                     ; sys_mmap
    mov rdi, 0                     ; let kernel choose address
    mov rsi, 17                    ; size (17 bytes)
    mov rdx, 3                     ; PROT_READ | PROT_WRITE
    mov r10, 34                    ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1                     ; fd (no file)
    mov r9, 0                      ; offset
    syscall

    ; Store value in node
    mov byte [rax], r12b           ; Store value

    ; If deque is empty, initialize head and tail
    cmp qword [head], 0
    je initialize_deque

    ; Insert node at the front
    mov rbx, [head]                ; Get old head
    mov qword [rax + 1], rbx       ; New node's next points to old head
    mov qword [rax + 9], 0         ; New node's prev points to NULL
    mov qword [rbx + 9], rax       ; Old head's prev points to new node
    mov qword [head], rax          ; Update head to new node
    jmp main_loop

add_node_back:
    call prompt_and_read_value
    ; Allocate memory for new node (17 bytes)
    mov rax, 9                     ; sys_mmap
    mov rdi, 0                     ; let kernel choose address
    mov rsi, 17                    ; size (17 bytes)
    mov rdx, 3                     ; PROT_READ | PROT_WRITE
    mov r10, 34                    ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1                     ; fd (no file)
    mov r9, 0                      ; offset
    syscall

    ; Store value in node
    mov byte [rax], r12b           ; Store value

    ; If deque is empty, initialize head and tail
    cmp qword [tail], 0
    je initialize_deque

    ; Insert node at the back
    mov rbx, [tail]                ; Get old tail
    mov qword [rax + 1], 0         ; New node's next points to NULL
    mov qword [rax + 9], rbx       ; New node's prev points to old tail
    mov qword [rbx + 1], rax       ; Old tail's next points to new node
    mov qword [tail], rax          ; Update tail to new node
    jmp main_loop

initialize_deque:
    mov qword [head], rax          ; Set head to new node
    mov qword [tail], rax          ; Set tail to new node
    mov qword [rax + 1], 0         ; Next points to NULL
    mov qword [rax + 9], 0         ; Prev points to NULL
    jmp main_loop

remove_node_front:
    ; Check if deque is empty
    cmp qword [head], 0
    je print_empty

    ; If only one node, reset head and tail
    mov rbx, [head]
    mov rcx, [rbx + 1]             ; Next node
    cmp rcx, 0
    je reset_deque

    ; Remove node from front
    mov rbx, [head]
    mov rcx, [rbx + 1]             ; Next node
    mov qword [head], rcx          ; Update head to next node
    mov qword [rcx + 9], 0         ; New head's prev points to NULL
    jmp main_loop

remove_node_back:
    ; Check if deque is empty
    cmp qword [tail], 0
    je print_empty

    ; If only one node, reset head and tail
    mov rbx, [tail]
    mov rcx, [rbx + 9]             ; Prev node
    cmp rcx, 0
    je reset_deque

    ; Remove node from back
    mov rbx, [tail]
    mov rcx, [rbx + 9]             ; Prev node
    mov qword [tail], rcx          ; Update tail to prev node
    mov qword [rcx + 1], 0         ; New tail's next points to NULL
    jmp main_loop

reset_deque:
    mov qword [head], 0
    mov qword [tail], 0
    jmp main_loop

display_deque:
    ; Print "Deque: "
    mov rsi, msg_deque
    call print_string

    ; Check if deque is empty
    cmp qword [head], 0
    je print_empty

    mov rbx, [head]                ; Start from head
print_loop:
    ; Print value
    movzx rax, byte [rbx]          ; Get value
    add rax, '0'                   ; Convert to ASCII
    push rax
    mov rsi, rsp
    mov rdx, 1
    call print_chars
    pop rax

    mov rbx, [rbx + 1]             ; Move to next node
    
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
    mov rax, 1                     ; sys_write
    mov rdi, 1                     ; stdout
    syscall
    ret

read_input:
    mov rax, 0                     ; sys_read
    mov rdi, 0                     ; stdin
    mov rsi, input_buf
    mov rdx, 2                     ; read 2 bytes (char + newline)
    syscall
    ret