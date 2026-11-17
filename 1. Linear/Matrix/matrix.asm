; Linux x86-64 NASM; a contiguous 5x5 matrix is initialized and printed by rows.
section .data
    msg_matrix db "5x5 Integer Matrix:", 10, 0
    newline db 10, 0
    space db " ", 0
section .bss
    matrix resd 25
    buffer resb 12
section .text
    global _start
_start:
    mov r12, matrix
    mov eax, 1
.initialize:
    mov [r12], eax
    add r12, 4
    inc eax
    cmp eax, 26
    jne .initialize
    mov rsi, msg_matrix
    call print_string
    mov r12, matrix
    mov r13d, 5
.row:
    mov r14d, 5
.column:
    mov eax, [r12]
    call int_to_string
    call print_string
    mov rsi, space
    call print_string
    add r12, 4
    dec r14d
    jnz .column
    mov rsi, newline
    call print_string
    dec r13d
    jnz .row
    mov eax, 60
    xor edi, edi
    syscall
print_string:
    xor edx, edx
.count:
    cmp byte [rsi + rdx], 0
    je .write
    inc rdx
    jmp .count
.write:
    mov eax, 1
    mov edi, 1
    syscall
    ret
int_to_string:
    mov rsi, buffer + 11
    mov byte [rsi], 0
    mov ecx, 10
.convert:
    dec rsi
    xor edx, edx
    div ecx
    add dl, '0'
    mov [rsi], dl
    test eax, eax
    jnz .convert
    ret
