; Linux x86-64 NASM; whitespace-separated single-digit input.
; Front and rear are circular byte-array indices; -1 represents an empty queue.

section .data
    input_error_message db "Expected one digit (0-9).", 10
    input_error_length equ $ - input_error_message
    queueSize equ 5
    menu db "Circular Queue Operations:", 10
         db "1. Enqueue", 10
         db "2. Dequeue", 10
         db "3. Peek", 10
         db "4. Display Queue", 10
         db "5. Exit", 10
         db "Enter your choice: ", 0
    enqueuePrompt db "Enter value to enqueue (0-9): ", 0
    dequeueMsg db "Dequeued value: ", 0
    peekMsg db "Front value: ", 0
    emptyMsg db "Queue is empty!", 10, 0
    fullMsg db "Queue is full!", 10, 0
    newline db 10, 0
section .bss
    queue resb queueSize
    front resd 1
    rear resd 1
    choice resb 2
    inputVal resb 2
    tempVal resb 1
section .text
    global _start
_start:
    mov dword [front], -1
    mov dword [rear], -1
main_loop:
    mov rsi, menu
    call print_string
    mov rsi, choice
    call read_input
    movzx rax, byte [choice]
    sub rax, '0'
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
    mov rsi, enqueuePrompt
    call print_string
    mov rsi, inputVal
    call read_input
    movzx r12, byte [inputVal]
    sub r12, '0'
    cmp r12, 0
    jl enqueue_invalid
    cmp r12, 9
    jg enqueue_invalid
    mov eax, [rear]
    mov ebx, [front]
    cmp eax, -1
    je first_enqueue
    inc eax
    mov ecx, queueSize
    xor edx, edx
    div ecx
    mov eax, edx
    cmp eax, ebx
    je queue_full
    jmp not_full
first_enqueue:
    mov eax, 0
    mov dword [front], 0
not_full:
    mov [rear], eax
    mov rbx, queue
    add rbx, rax
    mov [rbx], r12b
    mov rsi, newline
    call print_string
    jmp main_loop
enqueue_invalid:
    mov rsi, newline
    call print_string
    jmp main_loop
queue_full:
    mov rsi, fullMsg
    call print_string
    jmp main_loop
dequeue_value:
    cmp dword [front], -1
    je queue_empty
    mov eax, [front]
    mov rbx, queue
    add rbx, rax
    movzx rax, byte [rbx]
    mov [tempVal], al
    add byte [tempVal], '0'
    mov rsi, dequeueMsg
    call print_string
    mov rsi, tempVal
    mov rdx, 1
    call print_chars
    mov rsi, newline
    call print_string
    mov eax, [front]
    cmp eax, [rear]
    je reset_queue
    inc eax
    mov ecx, queueSize
    xor edx, edx
    div ecx
    mov eax, edx
    mov [front], eax
    jmp main_loop
reset_queue:
    mov dword [front], -1
    mov dword [rear], -1
    jmp main_loop
peek_value:
    cmp dword [front], -1
    je queue_empty
    mov eax, [front]
    mov rbx, queue
    add rbx, rax
    movzx rax, byte [rbx]
    mov [tempVal], al
    add byte [tempVal], '0'
    mov rsi, peekMsg
    call print_string
    mov rsi, tempVal
    mov rdx, 1
    call print_chars
    mov rsi, newline
    call print_string
    jmp main_loop
display_queue:
    cmp dword [front], -1
    je queue_empty
    mov rsi, newline
    call print_string
    mov r12d, [front]
display_loop:
    movzx eax, byte [queue + r12]
    add al, '0'
    mov [tempVal], al
    mov rsi, tempVal
    mov edx, 1
    call print_chars
    cmp r12d, [rear]
    je display_done
    inc r12d
    cmp r12d, queueSize
    jb display_loop
    xor r12d, r12d
    jmp display_loop
display_done:
    mov rsi, newline
    call print_string
    jmp main_loop

queue_empty:
    mov rsi, emptyMsg
    call print_string
    jmp main_loop
exit_program:
    mov rax, 60
    xor rdi, rdi
    syscall
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
    mov rax, 1
    mov rdi, 1
    syscall
    ret
read_input:
    mov r8, rsi
.read_first:
    xor eax, eax
    xor edi, edi
    mov rsi, r8
    mov edx, 1
    syscall
    cmp rax, -4
    je .read_first
    test rax, rax
    jz exit_program
    js input_error
    movzx r9d, byte [r8]
    cmp r9b, ' '
    je .read_first
    cmp r9b, 9
    jb input_error
    cmp r9b, 13
    jbe .read_first
    cmp r9b, '0'
    jb input_error
    cmp r9b, '9'
    ja input_error
.read_end:
    xor eax, eax
    xor edi, edi
    lea rsi, [r8 + 1]
    mov edx, 1
    syscall
    cmp rax, -4
    je .read_end
    test rax, rax
    jz .done
    js input_error
    mov al, [r8 + 1]
    cmp al, ' '
    je .done
    cmp al, 9
    jb input_error
    cmp al, 13
    ja input_error
.done:
    mov [r8], r9b
    ret

input_error:
    mov eax, 1
    mov edi, 2
    mov rsi, input_error_message
    mov edx, input_error_length
    syscall
    mov eax, 60
    mov edi, 1
    syscall

allocation_failed:
    mov eax, 60
    mov edi, 1
    syscall
