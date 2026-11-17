; Linux x86-64 NASM; whitespace-separated single-digit input.
; Nodes contain a one-byte value and an eight-byte next pointer at offset 1.

section .data
    input_error_message db "Expected one digit (0-9).", 10
    input_error_length equ $ - input_error_message
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
    top resq 1
    choice resb 2
    input_val resb 2
    temp_val resb 1
section .text
    global _start
_start:
    mov qword [top], 0
main_loop:
    mov rsi, menu
    call print_string
    mov rsi, choice
    call read_input
    mov al, [choice]
    sub al, '0'
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
    mov rsi, push_prompt
    call print_string
    mov rsi, input_val
    call read_input
    movzx r12, byte [input_val]
    sub r12, '0'
    mov rax, 9
    mov rdi, 0
    mov rsi, 9
    mov rdx, 3
    mov r10, 34
    mov r8, -1
    mov r9, 0
    syscall
    cmp rax, -4095
    jae allocation_failed
    mov byte [rax], r12b
    mov rbx, [top]
    mov [rax + 1], rbx
    mov [top], rax
    jmp main_loop
pop_value:
    cmp qword [top], 0
    je stack_empty
    mov rsi, pop_msg
    call print_string
    mov rbx, [top]
    movzx rax, byte [rbx]
    mov [temp_val], al
    add byte [temp_val], '0'
    mov rsi, temp_val
    mov rdx, 1
    call print_chars
    mov rsi, newline
    call print_string
    mov rax, [rbx + 1]
    mov [top], rax
    mov rdi, rbx
    mov esi, 9
    mov eax, 11
    syscall
    jmp main_loop
peek_value:
    cmp qword [top], 0
    je stack_empty
    mov rsi, peek_msg
    call print_string
    mov rbx, [top]
    movzx rax, byte [rbx]
    mov [temp_val], al
    add byte [temp_val], '0'
    mov rsi, temp_val
    mov rdx, 1
    call print_chars
    mov rsi, newline
    call print_string
    jmp main_loop
stack_empty:
    mov rsi, empty_msg
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
