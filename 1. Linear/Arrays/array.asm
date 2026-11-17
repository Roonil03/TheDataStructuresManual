; Linux x86-64 NASM; five single-digit values occupy consecutive array bytes.
section .data
    prompt db "Enter a digit (0-9): ", 0
    result db "You entered:", 10, 0
    newline db 10, 0
    input_error_message db "Expected one digit (0-9).", 10
    input_error_length equ $ - input_error_message
section .bss
    array resb 5
    input_buf resb 2
section .text
    global _start
_start:
    xor r12d, r12d
.input:
    mov rsi, prompt
    call print_string
    mov rsi, input_buf
    call read_input
    mov al, [input_buf]
    sub al, '0'
    mov [array + r12], al
    inc r12d
    cmp r12d, 5
    jb .input
    mov rsi, result
    call print_string
    xor r12d, r12d
.output:
    mov al, [array + r12]
    add al, '0'
    mov [input_buf], al
    mov rsi, input_buf
    mov edx, 1
    call print_chars
    mov rsi, newline
    call print_string
    inc r12d
    cmp r12d, 5
    jb .output
exit_program:
    mov eax, 60
    xor edi, edi
    syscall
print_string:
    xor edx, edx
.count:
    cmp byte [rsi + rdx], 0
    je print_chars
    inc rdx
    jmp .count
print_chars:
    mov eax, 1
    mov edi, 1
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
    jz input_error
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
