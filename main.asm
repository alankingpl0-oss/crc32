section .rodata
    poly        equ 0xEDB88320      
    BUF_SIZE    equ 4096            

    err_args    db "Błąd: Brak podanego pliku wejściowego.", 0xA
    err_args_l  equ $ - err_args

    err_open    db "Błąd: Nie można otworzyć pliku.", 0xA
    err_open_l  equ $ - err_open

    newline     db 0xA

section .bss
    buffer      resb BUF_SIZE       
    hex_out     resb 9              

section .text
    global _start

_start:
    
    pop rdi                         
    cmp rdi, 2
    jl .no_args                     

    
    pop rdi                         
    pop rdi                         

    
    mov rax, 2                      
    mov rsi, 0                      
    mov rdx, 0
    syscall

    cmp rax, 0
    jl .open_failed                 
    mov r12, rax                    

    
    mov r13d, 0xFFFFFFFF

.read_loop:
    
    mov rax, 0                      
    mov rdi, r12                    
    mov rsi, buffer                 
    mov rdx, BUF_SIZE               
    syscall

    cmp rax, 0
    je .file_eof                    
    jl .open_failed                 

    mov rcx, rax                    
    mov rsi, buffer                 

.process_buffer:
    
    movzx eax, byte [rsi]
    inc rsi

    
    xor r13b, al
    
    
    mov edx, 8
.bit_loop:
    mov eax, r13d
    shr r13d, 1                     
    and eax, 1                      
    cmp eax, 0
    je .no_xor                      
    xor r13d, poly                  
.no_xor:
    dec edx
    jnz .bit_loop

    dec rcx                         
    jnz .process_buffer

    jmp .read_loop                  

.file_eof:
    
    mov rax, 3                      
    mov rdi, r12
    syscall

    
    not r13d

    
    mov rdi, hex_out
    mov edx, r13d
    call uint32_to_hex

    
    mov rax, 1                      
    mov rdi, 1                      
    mov rsi, hex_out
    mov rdx, 9                      
    syscall

    
    mov rax, 60                     
    mov rdi, 0                      
    syscall

.no_args:
    mov rax, 1                      
    mov rdi, 2                      
    mov rsi, err_args
    mov rdx, err_args_l
    syscall
    mov rdi, 1
    jmp .exit_err

.open_failed:
    mov rax, 1                      
    mov rdi, 2                      
    mov rsi, err_open
    mov rdx, err_open_l
    syscall
    mov rdi, 2
    jmp .exit_err

.exit_err:
    mov rax, 60                     
    syscall








uint32_to_hex:
    mov rcx, 8                      
.loop:
    mov eax, edx
    shr eax, 28                     
    shl edx, 4                      

    and al, 0x0F                    
    cmp al, 9
    jbe .is_digit
    add al, 'A' - 10                
    jmp .store
.is_digit:
    add al, '0'                     
.store:
    mov [rdi], al                   
    inc rdi
    dec rcx
    jnz .loop

    mov byte [rdi], 0xA             
    ret