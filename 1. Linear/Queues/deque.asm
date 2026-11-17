; Linux x86-64 NASM; whitespace-separated single-digit input.
; Nodes contain a value byte, then next and previous pointers at offsets 1 and 9.

section .data
    input_error_message db "Expected one digit (0-9).", 10
    input_error_length equ $ - input_error_message
    prompt_menu db "1. Add node to front", 10, "2. Add node to back", 10, "3. Remove node from front", 10, "4. Remove node from back", 10, "5. Display deque", 10, "6. Exit", 10, "Choose option: ", 0
    prompt_value db "Enter a value (0-9): ", 0
    msg_deque db "Deque: ", 0
    space db " <-> ", 0
    newline db 10, 0
    empty_msg db "Deque is empty!", 10, 0
section .bss
    head resq 1
    tail resq 1
    input_buf resb 2
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
    cmp qword [head], 0
    je initialize_deque
    mov rbx, [head]
    mov qword [rax + 1], rbx
    mov qword [rax + 9], 0
    mov qword [rbx + 9], rax
    mov qword [head], rax
    jmp main_loop
add_node_back:
    call prompt_and_read_value
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
    cmp qword [tail], 0
    je initialize_deque
    mov rbx, [tail]
    mov qword [rax + 1], 0
    mov qword [rax + 9], rbx
    mov qword [rbx + 1], rax
    mov qword [tail], rax
    jmp main_loop
initialize_deque:
    mov qword [head], rax
    mov qword [tail], rax
    mov qword [rax + 1], 0
    mov qword [rax + 9], 0
    jmp main_loop
remove_node_front:
    cmp qword [head], 0
    je print_empty
    mov rbx, [head]
    mov rcx, [rbx + 1]
    cmp rcx, 0
    je reset_deque
    mov rbx, [head]
    mov rcx, [rbx + 1]
    mov qword [head], rcx
    mov qword [rcx + 9], 0
    jmp release_node
remove_node_back:
    cmp qword [tail], 0
    je print_empty
    mov rbx, [tail]
    mov rcx, [rbx + 9]
    cmp rcx, 0
    je reset_deque
    mov rbx, [tail]
    mov rcx, [rbx + 9]
    mov qword [tail], rcx
    mov qword [rcx + 1], 0
    jmp release_node
reset_deque:
    mov qword [head], 0
    mov qword [tail], 0
release_node:
    mov rdi, rbx
    mov esi, 17
    mov eax, 11
    syscall
    jmp main_loop
display_deque:
    mov rsi, msg_deque
    call print_string
    cmp qword [head], 0
    je print_empty
    mov rbx, [head]
print_loop:
    movzx rax, byte [rbx]
    add rax, '0'
    push rax
    mov rsi, rsp
    mov rdx, 1
    call print_chars
    pop rax
    mov rbx, [rbx + 1]
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
    mov rax, 60
    xor rdi, rdi
    syscall
prompt_and_read_value:
    mov rsi, prompt_value
    call print_string
    call read_input
    movzx r12, byte [input_buf]
    sub r12, '0'
    ret
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
