section .data
    msg_matrix db "5x5 Integer Matrix:", 10, 0
    newline db 10, 0
    space db " ", 0

section .bss
    matrix resd 25   ; Reserve space for a 5x5 matrix (25 integers)
    buffer resb 12   ; Buffer to convert integer to string (11 digits + null terminator)

section .text
    global _start

_start:
    ; Initialize the matrix with values from 1 to 25
    mov rdi, matrix
    mov eax, 1
    mov ecx, 25
init_loop:
    mov [rdi], eax
    add rdi, 4
    inc eax
    loop init_loop

    ; Print the matrix header
    mov rsi, msg_matrix
    call print_string

    ; Display the matrix
    mov rdi, matrix
    mov rcx, 5
row_loop:
    ; Display a row
    push rcx
    mov rcx, 5
col_loop:
    mov eax, [rdi]
    call int_to_string
    mov rsi, buffer
    call print_string
    mov rsi, space
    call print_string
    add rdi, 4
    loop col_loop

    ; Newline after each row
    mov rsi, newline
    call print_string

    pop rcx
    loop row_loop

    ; Exit the program
    mov eax, 60    ; sys_exit
    xor edi, edi   ; return 0
    syscall

print_string:
    ; Calculate string length
    mov rdx, 0
count_loop:
    cmp byte [rsi + rdx], 0
    je count_done
    inc rdx
    jmp count_loop
count_done:
    ; Print the string
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    syscall
    ret

int_to_string:
    ; Convert integer in EAX to string in buffer
    mov rdi, buffer + 11 ; Point to the end of the buffer
    mov byte [rdi], 0    ; Null-terminate the string
    dec rdi

    mov ecx, 10
convert_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test eax, eax
    jnz convert_loop
    inc rdi
    mov rsi, rdi
    ret