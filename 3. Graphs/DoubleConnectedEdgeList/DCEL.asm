section .data
    fmt_counts:  db "V=%d HE=%d F=%d", 10, 0

DCEL_VERTS    equ 0
DCEL_HEDGES   equ 8
DCEL_FACES    equ 16
DCEL_NV       equ 24
DCEL_NHE      equ 28
DCEL_NF       equ 32
DCEL_CAP_V    equ 36
DCEL_CAP_HE   equ 40
DCEL_CAP_F    equ 44
DCEL_SIZE     equ 48

VERT_X        equ 0
VERT_Y        equ 8
VERT_INC      equ 16
VERT_ID       equ 24
VERT_SIZE     equ 32

HE_ORIGIN     equ 0
HE_TWIN       equ 8
HE_NEXT       equ 16
HE_PREV       equ 24
HE_FACE       equ 32
HE_ID         equ 40
HE_SIZE       equ 48

FACE_EDGE     equ 0
FACE_ID       equ 8
FACE_SIZE     equ 16

section .text
    global main, dcel_create, dcel_add_vertex, dcel_add_face, dcel_add_edge_pair, dcel_free
    extern calloc, free, printf

dcel_create:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 16

    test edi, edi
    js .invalid
    test esi, esi
    js .invalid
    test edx, edx
    js .invalid
    mov r12d, edi
    mov r13d, esi
    mov r14d, edx
    mov edi, 1
    mov esi, DCEL_SIZE
    call calloc
    test rax, rax
    jz .done
    mov rbx, rax
    mov [rbx + DCEL_CAP_V], r12d
    mov [rbx + DCEL_CAP_HE], r13d
    mov [rbx + DCEL_CAP_F], r14d

    mov edi, r12d
    mov esi, VERT_SIZE
    call calloc
    mov [rbx + DCEL_VERTS], rax
    test r12d, r12d
    jz .half_edges
    test rax, rax
    jz .failed
.half_edges:
    mov edi, r13d
    mov esi, HE_SIZE
    call calloc
    mov [rbx + DCEL_HEDGES], rax
    test r13d, r13d
    jz .faces
    test rax, rax
    jz .failed
.faces:
    mov edi, r14d
    mov esi, FACE_SIZE
    call calloc
    mov [rbx + DCEL_FACES], rax
    test r14d, r14d
    jz .ready
    test rax, rax
    jz .failed
.ready:
    mov rax, rbx
    jmp .done
.failed:
    mov rdi, rbx
    call dcel_free
.invalid:
    xor eax, eax
.done:
    add rsp, 16
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

dcel_add_vertex:
    push rbp
    mov rbp, rsp

    mov eax, [rdi + DCEL_NV]
    cmp eax, [rdi + DCEL_CAP_V]
    jae .full
    mov rcx, [rdi + DCEL_VERTS]

    mov r8d, eax
    imul r8, VERT_SIZE

    mov qword [rcx + r8 + VERT_INC], 0
    mov dword [rcx + r8 + VERT_ID], eax
    inc dword [rdi + DCEL_NV]

    pop rbp
    ret
.full:
    mov eax, -1
    pop rbp
    ret

dcel_add_face:
    push rbp
    mov rbp, rsp

    mov eax, [rdi + DCEL_NF]
    cmp eax, [rdi + DCEL_CAP_F]
    jae .full
    mov rcx, [rdi + DCEL_FACES]

    mov r8d, eax
    imul r8, FACE_SIZE

    mov qword [rcx + r8 + FACE_EDGE], 0
    mov dword [rcx + r8 + FACE_ID], eax
    inc dword [rdi + DCEL_NF]

    pop rbp
    ret
.full:
    mov eax, -1
    pop rbp
    ret

dcel_add_edge_pair:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8

    cmp esi, [rdi + DCEL_NV]
    jae .done
    cmp edx, [rdi + DCEL_NV]
    jae .done
    mov eax, [rdi + DCEL_CAP_HE]
    sub eax, [rdi + DCEL_NHE]
    cmp eax, 2
    jl .done
    mov rbx, rdi
    mov r12d, esi
    mov r13d, edx

    mov eax, [rbx + DCEL_NHE]
    mov rcx, [rbx + DCEL_HEDGES]

    mov r8d, eax
    imul r8, HE_SIZE
    lea r9, [rcx + r8]

    mov r10d, eax
    inc r10d
    imul r10, HE_SIZE
    lea r11, [rcx + r10]

    mov dword [r9 + HE_ID], eax
    lea edx, [eax + 1]
    mov dword [r11 + HE_ID], edx

    mov rdx, [rbx + DCEL_VERTS]
    mov ecx, r12d
    imul rcx, VERT_SIZE
    lea rdi, [rdx + rcx]
    mov [r9 + HE_ORIGIN], rdi
    cmp qword [rdi + VERT_INC], 0
    jne .second
    mov [rdi + VERT_INC], r9
.second:

    mov ecx, r13d
    imul rcx, VERT_SIZE
    lea rdi, [rdx + rcx]
    mov [r11 + HE_ORIGIN], rdi
    cmp qword [rdi + VERT_INC], 0
    jne .twins
    mov [rdi + VERT_INC], r11
.twins:

    mov [r9 + HE_TWIN], r11
    mov [r11 + HE_TWIN], r9
    mov qword [r9 + HE_NEXT], 0
    mov qword [r9 + HE_PREV], 0
    mov qword [r9 + HE_FACE], 0
    mov qword [r11 + HE_NEXT], 0
    mov qword [r11 + HE_PREV], 0
    mov qword [r11 + HE_FACE], 0

    add dword [rbx + DCEL_NHE], 2
.done:

    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

dcel_free:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    mov rbx, rdi
    mov rdi, [rbx + DCEL_VERTS]
    call free
    mov rdi, [rbx + DCEL_HEDGES]
    call free
    mov rdi, [rbx + DCEL_FACES]
    call free
    mov rdi, rbx
    call free

    add rsp, 8
    pop rbx
    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    mov edi, 8
    mov esi, 16
    mov edx, 4
    call dcel_create
    test rax, rax
    jz .failure
    mov rbx, rax

    mov rdi, rbx
    call dcel_add_vertex
    mov rdi, rbx
    call dcel_add_vertex
    mov rdi, rbx
    call dcel_add_vertex
    mov rdi, rbx
    call dcel_add_vertex

    mov rdi, rbx
    call dcel_add_face
    mov rdi, rbx
    call dcel_add_face

    mov rdi, rbx
    mov esi, 0
    mov edx, 1
    call dcel_add_edge_pair

    mov rdi, rbx
    mov esi, 1
    mov edx, 2
    call dcel_add_edge_pair

    mov rdi, rbx
    mov esi, 2
    mov edx, 0
    call dcel_add_edge_pair

    lea rdi, [rel fmt_counts]
    mov esi, [rbx + DCEL_NV]
    mov edx, [rbx + DCEL_NHE]
    mov ecx, [rbx + DCEL_NF]
    xor eax, eax
    call printf

    mov rdi, rbx
    call dcel_free

    xor eax, eax
    jmp .done
.failure:
    mov eax, 1
.done:
    add rsp, 8
    pop rbx
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
