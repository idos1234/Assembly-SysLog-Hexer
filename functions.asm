%define SYS_OPEN 2
%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_CLOSE 3
%define SYS_EXIT 60

%define STDOUT 1

%define BUFFER_SIZE 1024

_open_file:
    enter 0, 0

    push rdi
    push rsi
    push rdx

    mov rax, SYS_OPEN
    mov rdi, [rbp + 10h]               ; address of the filename
    mov rsi, 0                      ; O_RDONLY (0) - Read-only mode
    mov rdx, 0                      ; No special permissions needed
    syscall

    pop rdx
    pop rsi
    pop rdi

    leave

    retn 8h

_read_file:
    enter 0, 0

    push rdi
    push rsi
    push rdx

    mov rax, SYS_READ
    mov rdi, [rbp + 18h]    ; file descriptor
    mov rsi, [rbp + 10h]    ; buffer to store the file
    mov rdx, BUFFER_SIZE
    syscall

    pop rdx
    pop rsi
    pop rdi

    leave

    retn 10h

_write_file_hex:
    enter 0, 0

    push rdi
    push rsi
    push rdx

    mov rcx, [rbp + 18h]    ; How many bytes actually read
    mov rsi, [rbp + 10h]    ; Pointer to the buffer containing the text
    _writing_loop:
        xor rax, rax
        mov al, byte [rsi]    ; Get the first char each time

        push rax
        call _print_char_as_hex

        add rsi, 1
        loop _writing_loop

    
    _stop_writing:
    pop rdx
    pop rsi
    pop rdi

    leave

    retn 10h

_close_file:
    enter 0, 0

    push rdi

    mov rax, SYS_CLOSE
    mov rdi, [rbp + 10h]               ; address of the filename
    syscall

    pop rdi

    leave

    retn 8h

_print_char_as_hex:
    enter 0, 0

    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, [rbp + 10h]
    push rax
    call _convert_char_to_hex

    mov rbx, rax

    ; Print the first char
    push rcx
    
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall

    pop rcx

    ; Print the second char
    push rbx

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall

    pop rbx

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx

    leave

    retn 8h



_convert_char_to_hex:
    enter 0, 0

    ; Get the left number
    mov rax, [rbp + 10h]
    shr rax, 4

    push rax
    call _convert_decimal_to_hex

    mov rcx, rax

    ; Get the right number
    mov rax, [rbp + 10h]
    and rax, 0x0F    ; 0x0F in binary is 00001111

    push rax
    call _convert_decimal_to_hex

    leave

    retn 8h

_convert_decimal_to_hex:
    enter 0, 0

    ; Get the number
    mov rax, [rbp + 10h]

    cmp rax, 9
    jbe _is_digit

    ; Is char
    sub rax, 10
    add rax, 'a'

    leave

    retn 8h

    _is_digit:
    add rax, '0'
    

    leave

    retn 8h
    

_exit:
    mov rax, SYS_EXIT
    syscall
