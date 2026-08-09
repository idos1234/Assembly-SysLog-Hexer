%define SYS_OPEN 2
%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_CLOSE 3
%define SYS_EXIT 60

%define STDOUT 1

%define BUFFER_SIZE 1024

_open_file:
    push rsi
    push rdx

    mov rax, SYS_OPEN
    mov rsi, 0                      ; O_RDONLY (0) - Read-only mode
    mov rdx, 0                      ; No special permissions needed
    syscall

    pop rdx
    pop rsi

    ret


_read_and_write:
    enter 0, 0

    push rbx
    push rdx

    xor rdx, rdx
    _read_and_write_loop:
        mov rdi, [rbp + 18h]    ; file descriptor
        mov rsi, [rbp + 10h]    ; buffer to store the file
        call _read_file

        cmp rax, 0
        jle _stop_reading_writing

        mov rbx, rdx    ; How many bytes already read - for the address
        shr rbx, 4        ; Divide by 16 to get the address
        push rbx
        add rdx, rax
        mov rbx, [rbp + 30h]    ; address of the space buffer
        push rbx
        mov rbx, [rbp + 28h]    ; address of the newline buffer
        push rbx
        mov rbx, [rbp + 20h]    ; address of the hex_text buffer
        push rbx
        push rax
        mov rax, [rbp + 10h]
        push rax

        call _write_file_hex

        cmp rax, 0
        jle _stop_reading_writing

        jmp _read_and_write_loop

    _stop_reading_writing:
    pop rdx
    pop rbx

    leave

    retn 30h

_read_file:
    push rdx

    mov rax, SYS_READ
    mov rdx, BUFFER_SIZE
    syscall

    pop rdx

    ret

_write_file_hex:
    enter 0, 0

    push rdi
    push rsi
    push rcx
    push rdx
    push rbx
    push r10

    mov rbx, [rbp + 18h]    ; How many bytes actually read
    mov rsi, [rbp + 10h]    ; Pointer to the buffer containing the text

    cmp rbx, 16
    jbe last_line_section

    mov r10, [rbp + 38h]    ; How many bytes already read - for the address

    _writing_loop:
        mov rcx, 16

        push r10
        mov rdx, [rbp + 20h]
        push rdx
        mov rdx, [rbp + 30h]
        push rdx
        call _print_line_offset

        push rcx
        push rsi
        mov rdx, [rbp + 20h]
        push rdx
        mov rdx, [rbp + 30h]
        push rdx
        call _print_hex_block

        mov rdx, 16
        mov rax, [rbp + 28h]
        call _print_ascii_sidebar
        
        inc r10

        add rsi, 16

        sub rbx, 16
        cmp rbx, 16
        jae _writing_loop
        
        cmp rbx, 0
        je _stop_writing


    last_line_section:  
    mov rcx, rbx

    push r10
    mov rdx, [rbp + 20h]
    push rdx
    mov rdx, [rbp + 30h]
    push rdx
    call _print_line_offset
    
    push rcx
    push rsi
    mov rdx, [rbp + 20h]
    push rdx
    mov rdx, [rbp + 30h]
    push rdx
    call _print_hex_block

    mov rdx, rcx
    mov rax, [rbp + 28h]
    call _print_ascii_sidebar


    _stop_writing:
    pop r10
    pop rbx
    pop rdx
    pop rcx
    pop rsi
    pop rdi

    leave

    retn 30h


_print_line_offset:
    enter 0, 0

    push rdx
    push rsi
    push rcx
    
    ; Print Address
    mov r8, 8   ; Minimum length of the hex to print
    mov rdi, [rbp + 18h]    ; Buffer to write the hex in
    mov rax, [rbp + 20h]
    shl rax, 4 ; Mul by 16
    call _print_decimal_as_hex

    ;':' + Space
    mov rsi, ':'
    push rsi

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall

    pop rsi

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, [rbp + 10h]
    mov rdx, 1
    syscall

    pop rcx
    pop rsi
    pop rdx

    leave

    retn 18h


_print_hex_block: ;
    enter 0, 0
    
    push rsi
    push rcx
    push rdx
    push rbx
    push r8


    mov rsi, [rbp + 20h]    ; Pointer to the buffer containing the text
    mov rcx, [rbp + 28h]    ; How many bytes actually read


    _write_line:
        xor rax, rax
        mov al, byte [rsi]    ; Get the first char each time

        mov r8, 2   ; Minimum length of the hex to print
        mov rdi, [rbp + 18h]    ; Buffer to write the hex in
        call _print_decimal_as_hex

        add rsi, 1

        mov rax, [rbp + 28h]
        sub rax, rcx
        xor rdx, rdx
        mov r8, 2
        div r8
        cmp rdx, 1
        je _write_space_1
        jmp _write_line_looper

        _write_space_1:
        push rsi
        push rcx

        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, [rbp + 10h]
        mov rdx, 1
        syscall

        pop rcx
        pop rsi

        _write_line_looper:
        loop _write_line

    ; Write spaces
    xor rcx, rcx

    ; The formula
    mov rax, 16
    sub rax, [rbp + 28h]
    mov rbx, rax
    shr rax, 1  ; / 2
    shl rbx, 1  ; * 2
    add rax, rbx
    add rax, 1  ; + 1

    ; Check odd or even
    push rax
    mov rax, [rbp + 28h]
    mov rbx, 2
    div rbx
    pop rax

    cmp rdx, 0
    je _space_looper

    add rax, 1
    _space_looper:
        push rsi
        push rcx
        push rax

        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, [rbp + 10h]
        mov rdx, 1
        syscall

        pop rax
        pop rcx
        pop rsi
    
        inc rcx
        cmp rcx, rax
        jb _space_looper

    pop r8
    pop rbx
    pop rdx
    pop rcx
    pop rsi

    leave

    retn 20h


_print_ascii_sidebar:
    push rsi
    push rbx

    ; Write text
    mov bh, 10  ;from
    mov bl, 46  ;to
    call _replace

    push rax

    mov rsi, rdi
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    syscall

    pop rax

    ; New line
    mov rsi, rax
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rdx, 1
    syscall 

    pop rbx
    pop rsi

    ret

_close_file:
    mov rax, SYS_CLOSE
    syscall

    ret

_print_decimal_as_hex:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    call _convert_decimal_to_hex

    mov rax, SYS_WRITE
    mov rsi, rdi
    mov rdi, STDOUT
    mov rdx, rcx
    syscall 


    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx

    ret



_convert_decimal_to_hex:
    push rbx
    push rdx

    add rdi, 7
    mov rbx, 10h
    mov rcx, 0

    _convert_decimal_to_hex_loop:
        xor rdx, rdx
        div rbx

        push rax
        mov rax, rdx
        call _convert_digit_to_hexChar

        mov byte [rdi], al
        pop rax
        
        dec rdi
        inc rcx
        cmp rcx, r8 ; Compare with the min lenght of the hex
        jb _convert_decimal_to_hex_loop

    add rdi, 1  ; Move the pointer to the first char of the hex

    pop rdx
    pop rbx

    ret

_convert_digit_to_hexChar:
    cmp rax, 9
    jbe _is_digit

    ; Is char
    sub rax, 10
    add rax, 'a'

    ret

    _is_digit:
    add rax, '0'

    ret

_replace:
    push rax
    push rcx

    mov rcx, 16

    _replace_loop:
        mov al, byte[rsi]

        cmp al, bh
        jne skip_replace

        mov al, bl
        mov byte [rsi], al


        skip_replace:
        inc rsi
        loop _replace_loop

    sub rsi, 16

    mov rdi, rsi

    pop rcx
    pop rax

    ret
    
    

_exit:
    mov rax, SYS_EXIT
    syscall

    ret
