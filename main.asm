%include "functions.asm"

default rel

SECTION .data
    newline db 10, 0
    space db 32, 0

SECTION .bss
    buffer resb BUFFER_SIZE
    file_desc resq 1
    hex_text resb 8

SECTION .text
    GLOBAL _start

_start:
    ; Check if the user provided an argument (argc >= 2)
    mov rax, [rsp]          ; rax = argc (number of arguments)
    cmp rax, 2
    jl .missing_argument    ; If no argument is provided, jump to error handling

    ; Retrieve argv[1] (pointer to the filename string)
    mov rdi, [rsp + 16]     ; rdi now holds the address of the filename from the terminal

    ; Since RDI already contains the address, we can directly call the file opening function!
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

    mov rdi, [file_desc]  ; address of the filename    
    call _close_file


    cmp rax, 0
    jl call_exit
    
    mov rax, 0


.missing_argument:
    mov rax, 1          ; Set return value to 1 (error)
    jmp call_exit

call_exit:
    mov rdi, rax    ; return value
    call _exit
