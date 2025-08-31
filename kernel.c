#include <stdint.h>

void kernel_main(uint32_t magic, uint32_t* mbi_addr) {
    volatile uint16_t* vga_text = (volatile uint16_t*)0xB8000;
    
    // Effacer l'écran texte
    for (int i = 0; i < 80 * 25; i++) {
        vga_text[i] = 0x0720;
    }
    
    if (magic != 0x2BADB002) {
        const char* error = "BAD MAGIC!";
        for (int i = 0; error[i]; i++) {
            vga_text[i] = 0x0C00 | error[i];
        }
        while(1);
    }
    
    const char* msg = "ENHANCED TEXT MODE GRAPHICS";
    for (int i = 0; msg[i]; i++) {
        vga_text[i] = 0x0A00 | msg[i];
    }
    
    // Utilisons le mode texte pour faire du "pseudo-graphique"
    // Chaque caractère peut avoir une couleur de fond et de premier plan
    
    // Créer un pattern coloré en utilisant des espaces avec couleurs de fond
    for (int y = 2; y < 20; y++) {
        for (int x = 0; x < 80; x++) {
            // Calculer une couleur basée sur la position
            uint8_t color = ((x * y) % 16) << 4; // Couleur de fond
            vga_text[y * 80 + x] = color | ' '; // Espace avec couleur de fond
        }
    }
    
    // Dessiner un "carré" rouge
    for (int y = 5; y < 10; y++) {
        for (int x = 10; x < 20; x++) {
            vga_text[y * 80 + x] = 0x4020; // Fond rouge, caractère espace
        }
    }
    
    // Dessiner un "carré" vert  
    for (int y = 5; y < 10; y++) {
        for (int x = 30; x < 40; x++) {
            vga_text[y * 80 + x] = 0x2020; // Fond vert, caractère espace
        }
    }
    
    // Dessiner un "carré" bleu
    for (int y = 5; y < 10; y++) {
        for (int x = 50; x < 60; x++) {
            vga_text[y * 80 + x] = 0x1020; // Fond bleu, caractère espace
        }
    }
    
    // Utiliser des caractères spéciaux pour plus de détails
    // Caractères ASCII étendus pour dessiner
    for (int y = 12; y < 18; y++) {
        for (int x = 10; x < 70; x++) {
            if ((x + y) % 4 == 0) {
                vga_text[y * 80 + x] = 0x0F00 | 0xDB; // Bloc plein blanc
            } else if ((x + y) % 4 == 1) {
                vga_text[y * 80 + x] = 0x0700 | 0xB0; // Bloc demi-ton
            } else if ((x + y) % 4 == 2) {
                vga_text[y * 80 + x] = 0x0800 | 0xB1; // Bloc quart-ton
            } else {
                vga_text[y * 80 + x] = 0x0000 | ' '; // Noir
            }
        }
    }
    
    // Message de succès
    const char* success = "TEXT MODE PSEUDO-GRAPHICS WORKING!";
    for (int i = 0; success[i]; i++) {
        vga_text[21 * 80 + i] = 0x0E00 | success[i]; // Jaune
    }
    
    while(1);
}