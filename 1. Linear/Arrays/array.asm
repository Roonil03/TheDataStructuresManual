; Program to input 5 integers and store them in memory
; 64-bit NASM code for Linux

section .data
    prompt db "Enter integer ", 0     ; Base prompt message
    prompt_num db " (0-9): ", 0       ; Continuation of prompt
    newline db 10                     ; Newline character

section .bss
    array resb 5                      ; Reserve 5 bytes for storing integers
    input_buf resb 2                  ; Buffer for user input (1 char + newline)

section .text
    global _start

_start:
    xor r8, r8                       ; r8 will be our counter (0 to 4)
    mov r9, array                    ; r9 holds the array address

input_loop:
    ; Print "Enter integer "
    mov rax, 1                      ; sys_write
    mov rdi, 1                      ; stdout
    mov rsi, prompt                 ; message to write
    mov rdx, 13                     ; length of the message
    syscall
    mov rax, r8
    inc rax                         ; Add 1 to get numbers 1-5 instead of 0-4
    add rax, '0'                    ; Convert to ASCII
    push rax                        ; Save the character
    mov rax, 1                      ; sys_write
    mov rdi, 1                      ; stdout
    mov rsi, rsp                    ; Point to the character on stack
    mov rdx, 1                      ; Length is 1 byte
    syscall
    pop rax                         ; Clean up stack
    mov rax, 1                      ; sys_write
    mov rdi, 1                      ; stdout
    mov rsi, prompt_num             ; message to write
    mov rdx, 8                      ; length of the message
    syscall
    mov rax, 0                      ; sys_read
    mov rdi, 0                      ; stdin
    mov rsi, input_buf              ; buffer to store input
    mov rdx, 2                      ; read 2 bytes (char + newline)
    syscall
    movzx rax, byte [input_buf]     ; Get the character
    sub rax, '0'                    ; Convert ASCII to integer
    mov byte [r9 + r8], al          ; Store in array
    inc r8                          ; Increment counter
    cmp r8, 5                       ; Check if we've input 5 numbers
    jl input_loop                   ; If less than 5, continue loop

exit:
    mov rax, 60                     ; sys_exit
    xor rdi, rdi                    ; return 0
    syscall