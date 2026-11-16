; Sparse octree over 0..255, using one coordinate bit per level.
BITS 64
default rel

section .data
menu db "Octree Operations:",10,"1. Insert point",10,"2. Search point",10,"3. Display tree",10,"4. Exit",10,"Enter choice: ",0
prompt db "Enter X Y Z (0-255): ",0
inserted db "Point inserted",10,0
found db "Found",10,0
missing db "Not Found",10,0
invalid db "Point is out of bound",10,0
space db " ",0
newline db 10,0

section .bss
root resq 1
coords resd 3
buf resb 16

section .text
global _start
_start:
    lea rsi, [menu]
    call print_string
    call read_number
    cmp eax, 4
    je do_exit
    cmp eax, 3
    je do_display
    cmp eax, 1
    je get_coords
    cmp eax, 2
    jne _start
get_coords:
    mov r12d, eax
    lea rsi, [prompt]
    call print_string
    call read_number
    mov [coords], eax
    call read_number
    mov [coords+4], eax
    call read_number
    mov [coords+8], eax
    mov ecx, 3
    lea rdi, [coords]
validate:
    cmp dword [rdi], 255
    ja out_of_bounds
    add rdi, 4
    loop validate
    cmp r12d, 1
    je do_insert
    jmp do_search
out_of_bounds:
    lea rsi, [invalid]
    call print_string
    jmp _start

do_insert:
    mov rbx, [root]
    test rbx, rbx
    jnz insert_root
    call new_node
    mov [root], rax
    mov rbx, rax
insert_root:
    mov r13d, 7
insert_level:
    call octant
    lea r14, [rbx+16+rax*8]
    mov rbx, [r14]
    test rbx, rbx
    jnz child_exists
    call new_node
    mov [r14], rax
    mov rbx, rax
child_exists:
    dec r13d
    jns insert_level
    mov eax, [coords]
    mov [rbx], eax
    mov eax, [coords+4]
    mov [rbx+4], eax
    mov eax, [coords+8]
    mov [rbx+8], eax
    mov dword [rbx+12], 1
    lea rsi, [inserted]
    call print_string
    jmp _start

do_search:
    mov rbx, [root]
    mov r13d, 7
search_level:
    test rbx, rbx
    jz not_found
    call octant
    mov rbx, [rbx+16+rax*8]
    dec r13d
    jns search_level
    test rbx, rbx
    jz not_found
    cmp dword [rbx+12], 1
    jne not_found
    lea rsi, [found]
    call print_string
    jmp _start
not_found:
    lea rsi, [missing]
    call print_string
    jmp _start

octant:
    mov ecx, r13d
    mov eax, [coords]
    shr eax, cl
    and eax, 1
    mov edx, [coords+4]
    shr edx, cl
    and edx, 1
    lea eax, [eax+edx*2]
    mov edx, [coords+8]
    shr edx, cl
    and edx, 1
    lea eax, [eax+edx*4]
    ret

do_display:
    mov rdi, [root]
    call display
    jmp _start

display:
    test rdi, rdi
    jz display_done
    push rbx
    push r12
    mov rbx, rdi
    cmp dword [rbx+12], 1
    jne display_children
    mov eax, [rbx]
    call print_number
    lea rsi, [space]
    call print_string
    mov eax, [rbx+4]
    call print_number
    lea rsi, [space]
    call print_string
    mov eax, [rbx+8]
    call print_number
    lea rsi, [newline]
    call print_string
display_children:
    xor r12d, r12d
display_loop:
    mov rdi, [rbx+16+r12*8]
    call display
    inc r12d
    cmp r12d, 8
    jl display_loop
    pop r12
    pop rbx
display_done:
    ret

new_node:
    mov eax, 9
    xor edi, edi
    mov esi, 80
    mov edx, 3
    mov r10d, 34
    mov r8, -1
    xor r9d, r9d
    syscall
    cmp rax, -4095
    jae input_error
    ret

read_number:
    xor r8d, r8d
    xor r9d, r9d
skip_space:
    call read_byte
    test eax, eax
    jz do_exit
    cmp byte [buf], 32
    jbe skip_space
    cmp byte [buf], '-'
    jne parse_digit
    mov r9d, 1
    call read_byte
    test eax, eax
    jz input_error
parse_digit:
    movzx edx, byte [buf]
    sub edx, '0'
    cmp edx, 9
    ja input_error
    cmp r8d, 214748364
    ja input_error
    imul r8d, r8d, 10
    add r8d, edx
    cmp r8d, 2147483647
    ja input_error
    call read_byte
    test eax, eax
    jz parsed
    cmp byte [buf], 32
    ja parse_digit
parsed:
    mov eax, r8d
    test r9d, r9d
    jz parsed_done
    neg eax
parsed_done:
    ret
read_byte:
    xor eax, eax
    xor edi, edi
    lea rsi, [buf]
    mov edx, 1
    syscall
    test rax, rax
    js input_error
    ret

print_string:
    xor edx, edx
string_length:
    cmp byte [rsi+rdx], 0
    je write_string
    inc edx
    jmp string_length
write_string:
    mov eax, 1
    mov edi, 1
    syscall
    ret

print_number:
    lea rsi, [buf+16]
    mov r10d, 10
    xor ecx, ecx
number_digit:
    xor edx, edx
    div r10d
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc ecx
    test eax, eax
    jnz number_digit
    mov edx, ecx
    mov eax, 1
    mov edi, 1
    syscall
    ret

do_exit:
    xor edi, edi
    jmp exit_status
input_error:
    mov edi, 1
exit_status:
    mov eax, 60
    syscall

section .note.GNU-stack noalloc noexec nowrite progbits
