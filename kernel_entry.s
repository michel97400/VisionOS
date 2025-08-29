global start
extern kmain

section .text
start:
    ; Le bootloader a déjà configuré esp = 0x90000
    call kmain       ; Appelle le kernel C
halt_loop:
    cli
    hlt
    jmp halt_loop