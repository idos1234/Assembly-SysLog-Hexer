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
    mov rdi, filename   ; address of the filename
    call _open_file

    mov [file_desc], rax    ; store the file descriptor

    cmp rax, 0
    jl call_exit

    mov r9, hex_text    ; address of the hex_text buffer
    mov r8, [file_desc]    ; file descriptor
    mov rsi, buffer     ; Buffer to store the file
    call _read_and_write

    cmp rax, 0
    jl call_exit

    mov rdi, file_desc  ; address of the filename    
    call _close_file


    cmp rax, 0
    jl call_exit
    
    mov rax, 0


call_exit:
    mov rdi, rax    ; return value
    call _exit
