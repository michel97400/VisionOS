[BITS 16]
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Affiche message initial
    mov si, msg_init
    call print_16

    ; Active A20
    call enable_a20
    mov si, msg_a20
    call print_16

    ; Charge le kernel (16 secteurs à 0x8000)
    mov ah, 0x02
    mov al, 16          ; Nombre de secteurs
    mov ch, 0           ; Cylindre 0
    mov cl, 2           ; Premier secteur après le bootloader
    mov dh, 0           ; Tête 0
    mov dl, 0x80        ; Disque principal
    mov bx, 0x8000      ; Adresse de chargement
    int 0x13
    jc .disk_error

    mov si, msg_kernel_loaded
    call print_16

    ; Charge GDT
    lgdt [gdt_descriptor]
    mov si, msg_gdt
    call print_16

    cli
    ; Passe en mode protégé
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_entry  ; Jump far vers le code 32 bits

.disk_error:
    mov si, msg_disk_error
    call print_16
    jmp $

; -------------------------------
; A20
enable_a20:
    in al, 0x64
.wait:
    test al, 2
    jnz .wait
    mov al, 0xD1
    out 0x64, al
.wait2:
    in al, 0x64
    test al, 2
    jnz .wait2
    mov al, 0xDF
    out 0x60, al
.wait3:
    in al, 0x64
    test al, 2
    jnz .wait3
    ret

; -------------------------------
; Affichage en mode réel
print_16:
    pusha
.next_char:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    jmp .next_char
.done:
    popa
    ret

; -------------------------------
[BITS 32]
protected_entry:
    ; Segments 32 bits
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Contrôle vers le kernel chargé à 0x8000
    jmp 0x08:0x8000

; -------------------------------
align 8
gdt_start:
    dq 0x0                 ; Null descriptor

    ; Code segment
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    ; Data segment
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; -------------------------------
msg_init db "Bootloader initialisation...", 13,10,0
msg_a20 db "Ligne A20 activée.", 13,10,0
msg_kernel_loaded db "Kernel loaded.",13,10,0
msg_gdt db "GDT chargée.",13,10,0
msg_disk_error db "Disk read error!",13,10,0

times 510-($-$$) db 0
dw 0xAA55