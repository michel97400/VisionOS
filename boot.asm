; boot.asm - Premier bootloader de VisionOS
BITS 16
ORG 0x7C00

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    mov ah, 0x0e
    mov si, msg

print_loop:
    lodsb
    cmp al, 0
    je done
    int 0x10
    jmp print_loop

done:
    hlt
    jmp done

msg db 'Bienvenue dans VisionOS!', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55