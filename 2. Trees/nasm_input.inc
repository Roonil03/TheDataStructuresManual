; Shared Linux x86-64 libc input for the standalone tree examples.
; Integer tokens are [+-]?[0-9]+, with a signed 32-bit range check.
; Leading zeroes have no length limit. Only ASCII whitespace separates tokens.
; Return 1 for a complete token, -1 for clean EOF before a token, or 0 on error.
; No integer destination is changed on failure. Invalid words are cleared.
extern getchar, ferror, stdin
section .text

; Return an unsigned byte, -1 for clean EOF, or -2 for a stream error.
tree_input_byte:
    sub rsp, 8
    call getchar
    cmp eax, -1
    jne .done
    mov rdi, [rel stdin]
    call ferror
    test eax, eax
    mov eax, -1
    jz .done
    mov eax, -2
.done:
    add rsp, 8
    ret

tree_input_start:
    sub rsp, 8
.skip:
    call tree_input_byte
    test eax, eax
    js .done
    cmp eax, 32
    je .skip
    lea ecx, [eax - 9]
    cmp ecx, 4
    jbe .skip
.done:
    add rsp, 8
    ret

; rdi = pointer to a signed dword.
tree_read_int:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12, rdi
    xor ebx, ebx
    xor r13d, r13d
    mov r14d, 2147483647
    call tree_input_start
    cmp eax, -1
    je .done
    test eax, eax
    js .invalid
    cmp eax, '-'
    jne .plus
    mov r13d, 1
    inc r14d
    jmp .sign
.plus:
    cmp eax, '+'
    jne .digit
.sign:
    call tree_input_byte
    test eax, eax
    js .invalid
    cmp eax, 32
    je .invalid
    lea ecx, [eax - 9]
    cmp ecx, 4
    jbe .invalid
.digit:
    sub eax, '0'
    cmp eax, 9
    ja .drain
    cmp ebx, 214748364
    ja .drain
    imul ebx, ebx, 10
    add ebx, eax
    cmp ebx, r14d
    ja .drain
    call tree_input_byte
    cmp eax, -1
    je .valid
    test eax, eax
    js .invalid
    cmp eax, 32
    je .valid
    lea ecx, [eax - 9]
    cmp ecx, 4
    jbe .valid
    jmp .digit
.drain:
    call tree_input_byte
    test eax, eax
    js .invalid
    cmp eax, 32
    je .invalid
    lea ecx, [eax - 9]
    cmp ecx, 4
    ja .drain
.invalid:
    xor eax, eax
    jmp .done
.valid:
    test r13d, r13d
    jz .store
    neg ebx
.store:
    mov [r12], ebx
    mov eax, 1
.done:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; rdi = buffer, esi = capacity including the terminating NUL (at least 1).
; Consume a whole word; overlong words and embedded NUL bytes are rejected.
tree_read_word:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12, rdi
    mov r13d, esi
    xor ebx, ebx
    xor r14d, r14d
    mov byte [r12], 0
    call tree_input_start
    cmp eax, -1
    je .done
    test eax, eax
    js .invalid
.byte:
    test eax, eax
    jz .bad_byte
    lea ecx, [rbx + 1]
    cmp ecx, r13d
    jae .bad_byte
    mov [r12 + rbx], al
    inc ebx
    jmp .next
.bad_byte:
    mov r14d, 1
.next:
    call tree_input_byte
    cmp eax, -1
    je .end_word
    test eax, eax
    js .invalid
    cmp eax, 32
    je .end_word
    lea ecx, [eax - 9]
    cmp ecx, 4
    ja .byte
.end_word:
    test r14d, r14d
    jnz .invalid
    mov byte [r12 + rbx], 0
    mov eax, 1
    jmp .done
.invalid:
    mov byte [r12], 0
    xor eax, eax
.done:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
