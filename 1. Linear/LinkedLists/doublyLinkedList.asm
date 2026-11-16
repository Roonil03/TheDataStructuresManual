; Linux x86-64 NASM; whitespace-separated single-digit input.
; Nodes contain a value byte, then next and previous pointers at offsets 1 and 9.

section .data
    input_error_message db "Expected one digit (0-9).", 10
    input_error_length equ $ - input_error_message
    prompt_menu db "1. Add node", 10, "2. Display list forward", 10, "3. Display list backward", 10, "4. Exit", 10, "Choose option: ", 0
    prompt_value db "Enter a value (0-9): ", 0
    msg_list_forward db "Linked List (Forward): ", 0
    msg_list_backward db "Linked List (Backward): ", 0
    space db " <-> ", 0
    null_msg db "NULL", 10, 0
    newline db 10, 0
section .bss
    head resq 1
    tail resq 1
    input_buf resb 2
    current resq 1
section .text
    global _start
_start:
    mov qword [head], 0
    mov qword [tail], 0
main_loop:
    mov rsi, prompt_menu
    call print_string
    call read_input
    movzx rax, byte [input_buf]
    sub rax, '0'
    cmp rax, 1
    je add_node
    cmp rax, 2
    je display_list_forward
    cmp rax, 3
    je display_list_backward
    cmp rax, 4
    je exit_program
    jmp main_loop
add_node:
    mov rsi, prompt_value
    call print_string
    call read_input
    movzx r12, byte [input_buf]
    sub r12, '0'
    mov rax, 9
    mov rdi, 0
    mov rsi, 17
    mov rdx, 3
    mov r10, 34
    mov r8, -1
    mov r9, 0
    syscall
    cmp rax, -4095
    jae allocation_failed
    mov byte [rax], r12b
    mov qword [rax + 1], 0
    mov qword [rax + 9], 0
    cmp qword [head], 0
    je set_first_node
    mov rbx, [tail]
    mov [rax + 9], rbx
    mov [rbx + 1], rax
    mov [tail], rax
    jmp main_loop
set_first_node:
    mov [head], rax
    mov [tail], rax
    jmp main_loop
display_list_forward:
    mov rsi, msg_list_forward
    call print_string
    mov rbx, [head]
    cmp rbx, 0
    je print_null
print_loop_forward:
    movzx rax, byte [rbx]
    add rax, '0'
    push rax
    mov rsi, rsp
    mov rdx, 1
    call print_chars
    pop rax
    cmp qword [rbx + 1], 0
    je print_null
    mov rsi, space
    call print_string
    mov rbx, [rbx + 1]
    jmp print_loop_forward
display_list_backward:
    mov rsi, msg_list_backward
    call print_string
    mov rbx, [tail]
    cmp rbx, 0
    je print_null
print_loop_backward:
    movzx rax, byte [rbx]
    add rax, '0'
    push rax
    mov rsi, rsp
    mov rdx, 1
    call print_chars
    pop rax
    cmp qword [rbx + 9], 0
    je print_null
    mov rsi, space
    call print_string
    mov rbx, [rbx + 9]
    jmp print_loop_backward
print_null:
    cmp qword [head], 0
    je .label
    mov rsi, space
    call print_string
.label:
    mov rsi, null_msg
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
    mov rsi, input_buf
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
