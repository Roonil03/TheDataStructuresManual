section .data
    menu db "Queue Operations:", 10
         db "1. Enqueue", 10
         db "2. Dequeue", 10
         db "3. Peek", 10
         db "4. Display Queue", 10
         db "5. Exit", 10
         db "Enter choice: ", 0

    enqueuePrompt db "Enter value to enqueue (0-9): ", 0
    dequeueMsg db "Dequeued value: ", 0
    peekMsg db "Front value: ", 0
    emptyMsg db "Queue is empty!", 10, 0
    newline db 10, 0

section .bss
    front resq 1         ; Points to the front of the queue
    rear resq 1          ; Points to the rear of the queue
    choice resb 2        ; For menu choice
    inputVal resb 2      ; For input value
    tempVal resb 1       ; For temporary value storage

section .text
    global _start

_start:
    mov qword [front], 0  ; Initialize front to NULL
    mov qword [rear], 0   ; Initialize rear to NULL

main_loop:
    ; Display menu
    mov rsi, menu
    call print_string

    ; Get choice
    mov rsi, choice
    call read_input
    movzx rax, byte [choice]  ; Explicitly specify size
    sub rax, '0'

    ; Menu handling
    cmp rax, 1
    je enqueue_value
    cmp rax, 2
    je dequeue_value
    cmp rax, 3
    je peek_value
    cmp rax, 4
    je display_queue
    cmp rax, 5
    je exit_program
    jmp main_loop

enqueue_value:
    ; Prompt for value
    mov rsi, enqueuePrompt
    call print_string

    ; Read value
    mov rsi, inputVal
    call read_input
    movzx r12, byte [inputVal]  ; Explicitly specify size
    sub r12, '0'

    ; Allocate new node (9 bytes: 1 for data, 8 for next pointer)
    mov rax, 9          ; sys_mmap
    mov rdi, 0          ; let kernel choose address
    mov rsi, 9          ; size
    mov rdx, 3          ; PROT_READ | PROT_WRITE
    mov r10, 34         ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1          ; fd
    mov r9, 0           ; offset
    syscall

    ; Store value and link
    mov byte [rax], r12b        ; Store value
    mov qword [rax + 1], 0      ; Set next pointer to NULL

    ; Update rear
    mov rbx, [rear]
    cmp rbx, 0
    je set_first_node
    mov qword [rbx + 1], rax    ; Link current rear to new node
    jmp update_rear

set_first_node:
    mov [front], rax            ; Set front to new node

update_rear:
    mov [rear], rax             ; Set rear to new node
    jmp main_loop

dequeue_value:
    ; Check if queue is empty
    cmp qword [front], 0
    je queue_empty

    ; Print message
    mov rsi, dequeueMsg
    call print_string

    ; Get value from front node
    mov rbx, [front]
    movzx rax, byte [rbx]  ; Explicitly specify size
    mov [tempVal], al      ; Store value temporarily
    add byte [tempVal], '0'  ; Convert to ASCII

    ; Print the value
    mov rsi, tempVal
    mov rdx, 1
    call print_chars

    ; Print newline
    mov rsi, newline
    call print_string

    ; Update front
    mov rax, [rbx + 1]         ; Get next node
    mov [front], rax           ; Update front
    cmp qword [front], 0
    jne skip_clear_rear
    mov qword [rear], 0        ; Clear rear if queue is empty

skip_clear_rear:
    jmp main_loop

peek_value:
    ; Check if queue is empty
    cmp qword [front], 0
    je queue_empty

    ; Print message
    mov rsi, peekMsg
    call print_string

    ; Get value from front node
    mov rbx, [front]
    movzx rax, byte [rbx]  ; Explicitly specify size
    mov [tempVal], al      ; Store value temporarily
    add byte [tempVal], '0'  ; Convert to ASCII

    ; Print the value
    mov rsi, tempVal
    mov rdx, 1
    call print_chars

    ; Print newline
    mov rsi, newline
    call print_string
    jmp main_loop

display_queue:
    ; Check if queue is empty
    cmp qword [front], 0
    je queue_empty

    ; Begin display
    mov rsi, newline
    call print_string

    ; Print all elements
    mov rbx, [front]
display_loop:
    movzx rax, byte [rbx]  ; Explicitly specify size
    mov [tempVal], al
    add byte [tempVal], '0'
    mov rsi, tempVal
    mov rdx, 1
    call print_chars

    ; Print space
    mov rsi, newline
    call print_string

    ; Move to next node
    mov rbx, [rbx + 1]
    cmp rbx, 0
    jne display_loop

    jmp main_loop

queue_empty:
    mov rsi, emptyMsg
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