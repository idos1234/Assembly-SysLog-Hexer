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
    push rcx
    push rdx

    mov rdx, [rbp + 20h]
    mov rcx, [rbp + 18h]    ; How many bytes actually read
    mov rsi, [rbp + 10h]    ; Pointer to the buffer containing the text
    _writing_loop:
        xor rax, rax
        mov al, byte [rsi]    ; Get the first char each time

        push rdx
        push rax
        call _print_decimal_as_hex

        add rsi, 1
        loop _writing_loop

    
    _stop_writing:
    pop rdx
    pop rcx
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

_print_decimal_as_hex:
    enter 0, 0

    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rsi, [rbp + 18h]
    push rsi
    mov rax, [rbp + 10h]
    push rax
    call _convert_decimal_to_hex

    add rsi, 8
    sub rsi, rcx

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rdx, rcx
    syscall 


    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx

    leave

    retn 10h



_convert_decimal_to_hex:
    enter 0, 0

    push rbx
    push rdx
    push rsi

    ; Get the number
    mov rsi, [rbp + 18h]
    add rsi, 7
    mov rax, [rbp + 10h]
    mov rbx, 10h
    mov rcx, 0

    _convert_decimal_to_hex_loop:
        xor rdx, rdx
        div rbx

        push rdx
        mov rdx, rax
        call _convert_digit_to_hexChar

        mov byte [rsi], al
        mov rax, rdx
        
        dec rsi
        inc rcx

        cmp rax, 0
        jne _convert_decimal_to_hex_loop


    pop rsi
    pop rdx
    pop rbx

    leave

    retn 10h

_convert_digit_to_hexChar:
    enter 0, 0

    push rdi
    push rsi
    push rdx

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
    

    pop rdx
    pop rsi
    pop rdi

    leave

    retn 8h
    

_exit:
    mov rax, SYS_EXIT
    syscall
