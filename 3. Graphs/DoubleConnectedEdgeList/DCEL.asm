section .data
    fmt_vert:    db "Vertices: %d", 10, 0
    fmt_vinfo:   db "  V%d: incident_he=%d", 10, 0
    fmt_he:      db "Half-Edges: %d", 10, 0
    fmt_heinfo:  db "  HE%d: origin=V%d twin=HE%d", 10, 0
    fmt_faces:   db "Faces: %d", 10, 0
    fmt_finfo:   db "  F%d: edge=HE%d", 10, 0
    fmt_counts:  db "V=%d HE=%d F=%d", 10, 0
    fmt_pass:    db "All tests passed.", 10, 0

DCEL_VERTS    equ 0
DCEL_HEDGES   equ 8
DCEL_FACES    equ 16
DCEL_NV       equ 24
DCEL_NHE      equ 28
DCEL_NF       equ 32
DCEL_SIZE     equ 40

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
    extern malloc, free, printf

dcel_create:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 16

    mov r12d, edi
    mov r13d, esi
    mov r14d, edx

    mov edi, DCEL_SIZE
    call malloc
    mov rbx, rax

    mov dword [rbx + DCEL_NV], 0
    mov dword [rbx + DCEL_NHE], 0
    mov dword [rbx + DCEL_NF], 0

    mov eax, r12d
    imul eax, VERT_SIZE
    movsxd rdi, eax
    call malloc
    mov [rbx + DCEL_VERTS], rax

    mov eax, r13d
    imul eax, HE_SIZE
    movsxd rdi, eax
    call malloc
    mov [rbx + DCEL_HEDGES], rax

    mov eax, r14d
    imul eax, FACE_SIZE
    movsxd rdi, eax
    call malloc
    mov [rbx + DCEL_FACES], rax

    mov rax, rbx
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
    mov rcx, [rdi + DCEL_VERTS]

    mov r8d, eax
    imul r8d, VERT_SIZE
    movsxd r8, r8d

    mov qword [rcx + r8 + VERT_INC], 0
    mov dword [rcx + r8 + VERT_ID], eax
    inc dword [rdi + DCEL_NV]

    pop rbp
    ret

dcel_add_face:
    push rbp
    mov rbp, rsp

    mov eax, [rdi + DCEL_NF]
    mov rcx, [rdi + DCEL_FACES]

    mov r8d, eax
    imul r8d, FACE_SIZE
    movsxd r8, r8d

    mov qword [rcx + r8 + FACE_EDGE], 0
    mov dword [rcx + r8 + FACE_ID], eax
    inc dword [rdi + DCEL_NF]

    pop rbp
    ret

dcel_add_edge_pair:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8

    mov rbx, rdi
    mov r12d, esi
    mov r13d, edx

    mov eax, [rbx + DCEL_NHE]
    mov rcx, [rbx + DCEL_HEDGES]

    mov r8d, eax
    imul r8d, HE_SIZE
    movsxd r8, r8d
    lea r9, [rcx + r8]

    mov r10d, eax
    inc r10d
    imul r10d, HE_SIZE
    movsxd r10, r10d
    lea r11, [rcx + r10]

    mov dword [r9 + HE_ID], eax
    lea edx, [eax + 1]
    mov dword [r11 + HE_ID], edx

    mov rdx, [rbx + DCEL_VERTS]
    mov ecx, r12d
    imul ecx, VERT_SIZE
    movsxd rcx, ecx
    lea rdi, [rdx + rcx]
    mov [r9 + HE_ORIGIN], rdi

    mov ecx, r13d
    imul ecx, VERT_SIZE
    movsxd rcx, ecx
    lea rdi, [rdx + rcx]
    mov [r11 + HE_ORIGIN], rdi

    mov [r9 + HE_TWIN], r11
    mov [r11 + HE_TWIN], r9
    mov qword [r9 + HE_NEXT], 0
    mov qword [r9 + HE_PREV], 0
    mov qword [r9 + HE_FACE], 0
    mov qword [r11 + HE_NEXT], 0
    mov qword [r11 + HE_PREV], 0
    mov qword [r11 + HE_FACE], 0

    add dword [rbx + DCEL_NHE], 2

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

    lea rdi, [rel fmt_pass]
    xor eax, eax
    call printf

    mov rdi, rbx
    call dcel_free

    xor eax, eax
    add rsp, 8
    pop rbx
    pop rbp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
