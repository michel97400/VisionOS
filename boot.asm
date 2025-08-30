[BITS 16]
[ORG 0x7C00]

start:
    ; Initialisation des segments
    cli                     ; Désactive les interruptions
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti                     ; Réactive les interruptions

    ; Affichage d'un message en mode réel
    mov si, msg_real_mode
    call print_string_16

    ; Activation de la ligne A20
    call enable_a20

    ; Chargement de la GDT
    lgdt [gdt_descriptor]

    ; Passage en mode protégé
    mov eax, cr0
    or eax, 1               ; Active le bit PE (Protection Enable)
    mov cr0, eax

    ; Saut vers le code en mode protégé
    jmp CODE_SEG:protected_mode

; Fonction pour afficher une chaîne en mode réel
print_string_16:
    mov ah, 0x0E            ; Fonction teletype
.loop:
    lodsb                   ; Charge le caractère suivant
    cmp al, 0
    je .done
    int 0x10                ; Interruption BIOS pour affichage
    jmp .loop
.done:
    ret

; === FONCTIONS VGA (VERSION COMPACTE) ===

; Configuration complète du mode VGA 320x200
set_vga_mode:
    pushad
    
    ; Désactiver l'affichage pendant la configuration
    mov dx, 0x3DA
    in al, dx
    mov dx, 0x3C0
    mov al, 0x00
    out dx, al
    
    ; Configuration séquenceur
    mov dx, 0x3C4
    mov al, 0x02
    out dx, al
    inc dx
    mov al, 0x0F
    out dx, al
    
    ; Configuration contrôleur graphique  
    mov dx, 0x3CE
    mov al, 0x06
    out dx, al
    inc dx
    mov al, 0x05    ; A0000-AFFFF, mode graphique
    out dx, al
    
    ; Mode couleur
    mov dx, 0x3C2
    mov al, 0x63    ; 25MHz, enable RAM
    out dx, al
    
    ; Réactiver l'affichage
    mov dx, 0x3DA
    in al, dx
    mov dx, 0x3C0
    mov al, 0x20
    out dx, al
    
    popad
    ret

; Motif de test simple mais visible
draw_test_pattern:
    pushad
    mov edi, 0xA0000
    
    ; Remplir l'écran avec un dégradé bleu
    mov ecx, 64000
    mov al, 1        ; Couleur de base (bleu)
.fill_loop:
    mov [edi], al
    inc edi
    inc al
    and al, 0x0F     ; Garder dans les couleurs 0-15
    add al, 1        ; Commencer à 1 (éviter le noir)
    loop .fill_loop
    
    ; Rectangle rouge bien visible 40x30 au centre
    mov edi, 0xA0000 + (85*320) + 140  ; Centre de l'écran
    mov edx, 30      ; Hauteur
.rect_y:
    mov ecx, 40      ; Largeur
    push edi
.rect_x:
    mov byte [edi], 4  ; Rouge vif
    inc edi
    loop .rect_x
    pop edi
    add edi, 320     ; Ligne suivante
    dec edx
    jnz .rect_y
    
    popad
    ret

; Activation de la ligne A20 (méthode simple)
enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

; === DÉBUT DU CODE EN MODE PROTÉGÉ ===
[BITS 32]
protected_mode:
    ; Désactiver les interruptions (critique en mode protégé)
    cli
    
    ; Configuration des segments
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Configuration de la pile (adresse plus basse et sûre)
    mov esp, 0x7000

    ; Effacement de l'écran
    call clear_screen

    ; Affichage du message principal
    mov esi, msg_protected_mode
    mov edi, 0xB8000        ; Adresse de la mémoire vidéo
    call print_string_32

    ; Affichage d'un message coloré
    mov esi, msg_welcome
    mov edi, 0xB8000 + (2 * 80 * 2)  ; Ligne 2
    mov ah, 0x2F            ; Couleur: texte blanc sur fond vert
    call print_string_color_32

    ; Attendre un peu
    mov ecx, 0x1FFFFF
wait_loop:
    dec ecx
    jnz wait_loop

    ; Passage en mode VGA 320x200 256 couleurs
    call set_vga_mode

    ; Dessiner des pixels de test
    call draw_test_pattern

    ; Boucle infinie stable
halt:
    hlt                     ; Met le processeur en veille
    jmp halt                ; Boucle sur halt

; Fonction pour effacer l'écran en mode protégé
clear_screen:
    mov edi, 0xB8000
    mov ecx, 80 * 25        ; 80 colonnes x 25 lignes
    mov ax, 0x0720          ; Espace avec attributs (noir sur gris)
.loop:
    mov [edi], ax
    add edi, 2
    loop .loop
    ret

; Fonction pour afficher une chaîne en mode protégé (blanc sur noir)
print_string_32:
    mov ah, 0x0F            ; Attribut: blanc sur noir
.loop:
    lodsb
    cmp al, 0
    je .done
    mov [edi], ax           ; Écrit le caractère et l'attribut
    add edi, 2
    jmp .loop
.done:
    ret

; Fonction pour afficher une chaîne avec couleur personnalisée
print_string_color_32:
.loop:
    lodsb
    cmp al, 0
    je .done
    mov [edi], ax           ; ah contient déjà la couleur
    add edi, 2
    jmp .loop
.done:
    ret

; === DONNÉES ===
msg_real_mode db 'Boot -> Mode protege -> VGA', 13, 10, 0
msg_protected_mode db 'Mode protege OK! VGA...', 0
msg_welcome db 'VGA 320x200 en cours...', 0

; === GLOBAL DESCRIPTOR TABLE (GDT) ===
gdt_start:

gdt_null:                   ; Descripteur null obligatoire
    dd 0x0
    dd 0x0

gdt_code:                   ; Segment de code
    dw 0xFFFF               ; Limite (bits 0-15)
    dw 0x0                  ; Base (bits 0-15)
    db 0x0                  ; Base (bits 16-23)
    db 10011010b            ; Flags: present, ring 0, code segment
    db 11001111b            ; Limite (bits 16-19) + flags
    db 0x0                  ; Base (bits 24-31)

gdt_data:                   ; Segment de données
    dw 0xFFFF               ; Limite (bits 0-15)
    dw 0x0                  ; Base (bits 0-15)
    db 0x0                  ; Base (bits 16-23)
    db 10010010b            ; Flags: present, ring 0, data segment
    db 11001111b            ; Limite (bits 16-19) + flags
    db 0x0                  ; Base (bits 24-31)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1    ; Taille de la GDT
    dd gdt_start                  ; Adresse de la GDT

; Constantes pour les sélecteurs de segments
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Signature du secteur de démarrage
times 510-($-$$) db 0
dw 0xAA55