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

        mov r10, rdx    ; How many bytes already read - for the address
        shr r10, 4        ; Divide by 16 to get the address
        mov rdi, [rbp + 20h]    ; address of the hex_text buffer
        mov rbx, rax    ; How many bytes actually read
        mov rsi, [rbp + 10h]    ; Pointer to the buffer containing the text
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
    push rdi
    push rsi
    push rcx
    push rdx
    push rbx
    push r10


    cmp rbx, 16
    jbe last_line_section


    _writing_loop:
        mov rcx, 16

        mov rax, r10    ; Push the line offset
        call _print_line_offset

        call _print_hex_block

        mov rdx, 16
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

    mov rax, r10
    call _print_line_offset
    
    call _print_hex_block

    mov rdx, rcx
    call _print_ascii_sidebar


    _stop_writing:
    pop r10
    pop rbx
    pop rdx
    pop rcx
    pop rsi
    pop rdi

    ret


_print_line_offset:
    push rdx
    push rsi
    push rcx
    push rdi
    
    ; Print Address
    mov r8, 8   ; Minimum length of the hex to print
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

    mov rsi, ' '
    push rsi

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall

    pop rsi

    pop rdi
    pop rcx
    pop rsi
    pop rdx

    ret


_print_hex_block:
    push rsi
    push rcx
    push rdx
    push rbx
    push r8
    push r9
    push rdi

    mov r9, rcx    ; How many bytes to print


    _write_line:
        xor rax, rax
        mov al, byte [rsi]    ; Get the first char each time

        mov r8, 2   ; Minimum length of the hex to print
        call _print_decimal_as_hex

        add rsi, 1

        mov rax, r9
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
        push rdi

        mov rsi, ' '
        push rsi

        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, rsp
        mov rdx, 1
        syscall

        pop rsi

        pop rdi
        pop rcx
        pop rsi

        _write_line_looper:
        loop _write_line

    ; Write spaces
    xor rcx, rcx

    ; The formula
    mov rax, 16
    sub rax, r9
    mov rbx, rax
    shr rax, 1  ; / 2
    shl rbx, 1  ; * 2
    add rax, rbx
    add rax, 1  ; + 1

    ; Check odd or even
    push rax
    mov rax, r9
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
        push rdi

        mov rsi, 32
        push rsi

        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, rsp
        mov rdx, 1
        syscall

        pop rsi

        pop rdi
        pop rax
        pop rcx
        pop rsi
    
        inc rcx
        cmp rcx, rax
        jb _space_looper

    pop rdi
    pop r9
    pop r8
    pop rbx
    pop rdx
    pop rcx
    pop rsi

    ret


_print_ascii_sidebar:
    push rsi
    push rbx
    push rdi

    ; Write text
    mov bh, 10  ;from
    mov bl, 46  ;to
    call _replace


    mov rsi, rdi
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    syscall

    ; New line
    mov rsi, 10
    push rsi

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall 

    pop rsi

    pop rdi
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
