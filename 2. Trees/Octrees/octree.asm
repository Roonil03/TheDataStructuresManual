; octree.asm – Working Octree in NASM x86_64
; Supports insertion, search, and display for a single point

section .data
    menu        db "Octree Operations:",10
                db "1. Insert point",10
                db "2. Search point",10
                db "3. Display point",10
                db "4. Exit",10
                db "Enter choice: ",0

    prompt_x    db "Enter X (0-255): ",0
    prompt_y    db "Enter Y (0-255): ",0
    prompt_z    db "Enter Z (0-255): ",0

    msg_inserted    db "Inserted",10,0
    msg_not_found   db "Not Found",10,0
    msg_found       db "Found: ",0
    newline         db 10,0
    space           db 32,0

section .bss
    root        resq 1       ; pointer to root node
    buf         resb 16
    tx          resd 1
    ty          resd 1
    tz          resd 1

section .text
    global _start

_start:
    mov qword [root], 0

main_loop:
    mov rsi, menu
    call print_string
    call read_digit
    sub al, '0'
    cmp al, 1
    je do_insert
    cmp al, 2
    je do_search
    cmp al, 3
    je do_display
    cmp al, 4
    je do_exit
    jmp main_loop

do_insert:
    ; Read coordinates
    mov rsi, prompt_x
    call print_string
    call read_number
    mov [tx], eax
    
    mov rsi, prompt_y
    call print_string
    call read_number
    mov [ty], eax
    
    mov rsi, prompt_z
    call print_string
    call read_number
    mov [tz], eax

    ; Validate 0<=coord<=255
    mov eax, [tx]
    cmp eax, 0
    jl ins_fail
    cmp eax, 255
    jg ins_fail
    
    mov eax, [ty]
    cmp eax, 0
    jl ins_fail
    cmp eax, 255
    jg ins_fail
    
    mov eax, [tz]
    cmp eax, 0
    jl ins_fail
    cmp eax, 255
    jg ins_fail

    ; If no root, allocate
    mov rdi, [root]
    test rdi, rdi
    jnz store_point
    
    call mk_node
    test rax, rax
    jz ins_fail
    
    mov [root], rax
    mov rdi, rax

store_point:
    mov eax, [tx]
    mov [rdi + 4], eax
    mov eax, [ty]
    mov [rdi + 8], eax
    mov eax, [tz]
    mov [rdi + 12], eax
    
    mov rsi, msg_inserted
    call print_string
    jmp main_loop

ins_fail:
    mov rsi, msg_not_found
    call print_string
    jmp main_loop

do_search:
    mov rsi, prompt_x
    call print_string
    call read_number
    mov [tx], eax
    
    mov rsi, prompt_y
    call print_string
    call read_number
    mov [ty], eax
    
    mov rsi, prompt_z
    call print_string
    call read_number
    mov [tz], eax

    mov rdi, [root]
    test rdi, rdi
    jz sr_fail
    
    mov eax, [tx]
    cmp eax, [rdi + 4]
    jne sr_fail
    
    mov eax, [ty]
    cmp eax, [rdi + 8]
    jne sr_fail
    
    mov eax, [tz]
    cmp eax, [rdi + 12]
    jne sr_fail
    
    mov rsi, msg_found
    call print_string
    
    ; print coords
    mov eax, [tx]
    call print_number
    mov rsi, newline
    call print_string
    jmp main_loop

sr_fail:
    mov rsi, msg_not_found
    call print_string
    jmp main_loop

do_display:
    mov rdi, [root]
    test rdi, rdi
    jz dp_fail
    
    mov eax, [rdi + 4]
    call print_number
    mov rsi, space
    call print_string
    
    mov eax, [rdi + 8]
    call print_number
    mov rsi, space
    call print_string
    
    mov eax, [rdi + 12]
    call print_number
    mov rsi, newline
    call print_string
    jmp main_loop

dp_fail:
    mov rsi, msg_not_found
    call print_string
    jmp main_loop

do_exit:
    mov rax, 60
    xor rdi, rdi
    syscall

; Allocate 32-byte node
mk_node:
    mov rax, 9          ; sys_mmap
    xor rdi, rdi        ; addr = 0
    mov rsi, 32         ; length
    mov rdx, 3          ; PROT_READ | PROT_WRITE
    mov r10, 34         ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1          ; fd
    mov r9, 0           ; offset
    syscall
    
    cmp rax, -1
    je mk_fail
    
    ; Clear the allocated memory
    push rdi
    push rcx
    push rax
    mov rdi, rax
    mov rcx, 32
    xor eax, eax
    rep stosb
    pop rax
    pop rcx
    pop rdi
    ret

mk_fail:
    xor rax, rax
    ret

; I/O helpers
read_digit:
    call clear_buf
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buf
    mov rdx, 2
    syscall
    mov al, [buf]
    ret

read_number:
    call clear_buf
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buf
    mov rdx, 16
    syscall
    
    ; Parse the number
    xor rax, rax
    xor rcx, rcx

parse_loop:
    mov dl, [buf + rcx]
    cmp dl, 10          ; newline
    je parse_done
    cmp dl, 13          ; carriage return
    je parse_done
    cmp dl, '0'
    jb next_char
    cmp dl, '9'
    ja next_char
    
    sub dl, '0'
    imul rax, rax, 10
    movzx rdx, dl
    add rax, rdx

next_char:
    inc rcx
    cmp rcx, 16
    jb parse_loop

parse_done:
    ret

print_string:
    push rsi
    push rdx
    xor rdx, rdx

count_chars:
    cmp byte [rsi + rdx], 0
    je write_string
    inc rdx
    jmp count_chars

write_string:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    pop rdx
    pop rsi
    ret

print_number:
    push rcx
    push rbx
    push rdx
    
    test eax, eax
    jnz convert_number
    
    ; Handle zero
    mov rsi, space      ; reuse space buffer
    mov byte [space], '0'
    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall
    jmp print_num_done

convert_number:
    xor rcx, rcx
    mov ebx, 10

convert_loop:
    xor rdx, rdx
    div ebx
    push rdx
    inc rcx
    test eax, eax
    jnz convert_loop

print_digits:
    test rcx, rcx
    jz print_num_done
    pop rax
    add al, '0'
    mov [buf], al
    mov rsi, buf
    mov rdx, 1
    push rcx
    mov rax, 1
    mov rdi, 1
    syscall
    pop rcx
    dec rcx
    jmp print_digits

print_num_done:
    pop rdx
    pop rbx
    pop rcx
    ret

clear_buf:
    push rdi
    push rcx
    push rax
    mov rdi, buf
    mov rcx, 16
    xor eax, eax
    rep stosb
    pop rax
    pop rcx
    pop rdi
    ret