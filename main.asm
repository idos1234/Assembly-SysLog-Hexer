%include "functions.asm"

default rel

SECTION .data
    filename db "file.txt", 0
    newline db 10, 0
    space db 32, 0

SECTION .bss
    buffer resb BUFFER_SIZE
    file_desc resq 1
    hex_text resb 8

SECTION .text
    GLOBAL _start

_start:
    mov rax, filename
    push rax

    call _open_file

    mov [file_desc], rax

    cmp rax, 0
    jl call_exit

    push rax
    mov rax, buffer
    push rax

    call _read_file

    cmp rax, 0
    jl call_exit

    push space
    push newline
    push hex_text
    push rax
    mov rax, buffer
    push rax

    call _write_file_hex

    cmp rax, 0
    jl call_exit

    mov rax, file_desc
    push rax
    
    call _close_file


    cmp rax, 0
    jl call_exit
    
    mov rax, 0


call_exit:
    mov rdi, rax
    call _exit
