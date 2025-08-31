#include <stdint.h>

// Définitions couleurs VGA
#define VGA_COLOR_BLACK         0
#define VGA_COLOR_BLUE          1
#define VGA_COLOR_GREEN         2
#define VGA_COLOR_CYAN          3
#define VGA_COLOR_RED           4
#define VGA_COLOR_MAGENTA       5
#define VGA_COLOR_BROWN         6
#define VGA_COLOR_LIGHT_GREY    7
#define VGA_COLOR_DARK_GREY     8
#define VGA_COLOR_LIGHT_BLUE    9
#define VGA_COLOR_LIGHT_GREEN   10
#define VGA_COLOR_LIGHT_CYAN    11
#define VGA_COLOR_LIGHT_RED     12
#define VGA_COLOR_LIGHT_MAGENTA 13
#define VGA_COLOR_YELLOW        14
#define VGA_COLOR_WHITE         15

#define VGA_WIDTH 80
#define VGA_HEIGHT 25

volatile uint16_t* vga_buffer = (volatile uint16_t*)0xB8000;

// Fonctions graphiques essentielles
void clear_screen(uint8_t bg_color) {
    uint16_t blank = (bg_color << 8) | ' ';
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i] = blank;
    }
}

void put_char_at(int x, int y, char c, uint8_t fg_color, uint8_t bg_color) {
    if (x >= 0 && x < VGA_WIDTH && y >= 0 && y < VGA_HEIGHT) {
        uint16_t color = (bg_color << 12) | (fg_color << 8);
        vga_buffer[y * VGA_WIDTH + x] = color | c;
    }
}

void print_string(int x, int y, const char* str, uint8_t fg_color, uint8_t bg_color) {
    for (int i = 0; str[i] != '\0'; i++) {
        put_char_at(x + i, y, str[i], fg_color, bg_color);
    }
}

void draw_rect(int x, int y, int width, int height, uint8_t color) {
    for (int dy = 0; dy < height; dy++) {
        for (int dx = 0; dx < width; dx++) {
            put_char_at(x + dx, y + dy, ' ', 0, color);
        }
    }
}

void draw_border(int x, int y, int width, int height, uint8_t color) {
    // Bordure horizontale
    for (int i = 0; i < width; i++) {
        put_char_at(x + i, y, 0xC4, color, VGA_COLOR_BLACK);           // Top
        put_char_at(x + i, y + height - 1, 0xC4, color, VGA_COLOR_BLACK); // Bottom
    }
    
    // Bordure verticale
    for (int i = 0; i < height; i++) {
        put_char_at(x, y + i, 0xB3, color, VGA_COLOR_BLACK);               // Left
        put_char_at(x + width - 1, y + i, 0xB3, color, VGA_COLOR_BLACK);   // Right
    }
    
    // Coins
    put_char_at(x, y, 0xDA, color, VGA_COLOR_BLACK);                       // Top-left
    put_char_at(x + width - 1, y, 0xBF, color, VGA_COLOR_BLACK);           // Top-right
    put_char_at(x, y + height - 1, 0xC0, color, VGA_COLOR_BLACK);          // Bottom-left
    put_char_at(x + width - 1, y + height - 1, 0xD9, color, VGA_COLOR_BLACK); // Bottom-right
}

void draw_welcome_screen() {
    clear_screen(VGA_COLOR_LIGHT_GREY);
    
    // Titre principal avec fond bleu
    draw_rect(0, 0, VGA_WIDTH, 3, VGA_COLOR_BLUE);
    print_string(30, 1, "VisionOS v1.0", VGA_COLOR_WHITE, VGA_COLOR_BLUE);
    
    // Logo ASCII art simple
    print_string(35, 5, " __   __", VGA_COLOR_CYAN, VGA_COLOR_BLACK);
    print_string(35, 6, " \\ \\ / /", VGA_COLOR_CYAN, VGA_COLOR_BLACK);
    print_string(35, 7, "  \\ V / ", VGA_COLOR_CYAN, VGA_COLOR_BLACK);
    print_string(35, 8, "   \\_/  ", VGA_COLOR_CYAN, VGA_COLOR_BLACK);
    print_string(35, 9, "VisionOS", VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);
    
    // Informations système dans un cadre
    draw_border(25, 12, 30, 8, VGA_COLOR_GREEN);
    print_string(30, 13, "System Information:", VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    print_string(30, 14, "Architecture: x86", VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    print_string(30, 15, "Kernel: VisionOS v1.0", VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    print_string(30, 16, "Memory: Available", VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    print_string(30, 17, "Graphics: VGA Text Mode", VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    print_string(30, 18, "Status: Running", VGA_COLOR_GREEN, VGA_COLOR_BLACK);
    
    // Barre de statut en bas
    draw_rect(0, VGA_HEIGHT - 2, VGA_WIDTH, 2, VGA_COLOR_DARK_GREY);
    print_string(2, VGA_HEIGHT - 2, "Welcome to VisionOS!", VGA_COLOR_WHITE, VGA_COLOR_DARK_GREY);
    print_string(2, VGA_HEIGHT - 1, "Press any key to continue...", VGA_COLOR_LIGHT_GREY, VGA_COLOR_DARK_GREY);
    
    // Copyright
    print_string(50, VGA_HEIGHT - 1, "(C) 2025 VisionOS", VGA_COLOR_LIGHT_GREY, VGA_COLOR_DARK_GREY);
}


void desktop_environment() {
    clear_screen(VGA_COLOR_LIGHT_GREEN);
    
    // Calculs pour centrer le cadre (30 de large, 15 de haut)
    int frame_width = 30;
    int frame_height = 15;
    int frame_x = (VGA_WIDTH - frame_width) / 2;    // Centre horizontalement
    int frame_y = (VGA_HEIGHT - frame_height) / 2;  // Centre verticalement
    
    // Dessiner le cadre centré
    draw_border(frame_x, frame_y, frame_width, frame_height, VGA_COLOR_BLUE);
    
    // Titre centré dans le cadre
    char* title = "Desktop Environment";
    int title_len = 18; // Longueur de "Desktop Environment"
    int title_x = frame_x + (frame_width - title_len) / 2;
    int title_y = frame_y + 2; // 2 lignes depuis le haut du cadre
    print_string(title_x, title_y, title, VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    
    // Menu centré dans le cadre
    int menu_start_y = title_y + 3; // 3 lignes après le titre
    
    // Chaque option du menu centrée
    char* option1 = "[1] File Manager";
    int opt1_len = 16;
    int opt1_x = frame_x + (frame_width - opt1_len) / 2;
    print_string(opt1_x, menu_start_y, option1, VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    
    char* option2 = "[2] Web Browser";
    int opt2_len = 15;
    int opt2_x = frame_x + (frame_width - opt2_len) / 2;
    print_string(opt2_x, menu_start_y + 1, option2, VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    
    char* option3 = "[3] Text Editor";
    int opt3_len = 15;
    int opt3_x = frame_x + (frame_width - opt3_len) / 2;
    print_string(opt3_x, menu_start_y + 2, option3, VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    
    char* option4 = "[4] Settings";
    int opt4_len = 12;
    int opt4_x = frame_x + (frame_width - opt4_len) / 2;
    print_string(opt4_x, menu_start_y + 3, option4, VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    
    // Prompt centré en bas du cadre
    char* prompt = "Select an option:";
    int prompt_len = 17;
    int prompt_x = frame_x + (frame_width - prompt_len) / 2;
    int prompt_y = frame_y + frame_height - 3; // 3 lignes avant le bas du cadre
    print_string(prompt_x, prompt_y, prompt, VGA_COLOR_YELLOW, VGA_COLOR_BLACK);
}

// I/O pour le clavier
static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

uint8_t get_key() {
    if (inb(0x64) & 0x01) {
        return inb(0x60);
    }
    return 0;
}

void wait_for_key() {
    while (1) {
        if (get_key() != 0) {
            break;
        }
        // Petit délai
        for (volatile int i = 0; i < 100000; i++);
    }
}

void show_loading() {
    clear_screen(VGA_COLOR_DARK_GREY);
    
    // Écran de boot
    print_string(30, 8, "VisionOS Booting...", VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    
    // Barre de progression ASCII
    print_string(25, 12, "[", VGA_COLOR_GREEN, VGA_COLOR_BLACK);
    print_string(55, 12, "]", VGA_COLOR_GREEN, VGA_COLOR_BLACK);
    
    for (int i = 0; i < 28; i++) {
        put_char_at(26 + i, 12, 0xDB, VGA_COLOR_GREEN, VGA_COLOR_BLACK);
        
        // Messages de boot
        if (i == 5) print_string(25, 14, "Loading kernel modules...", VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
        if (i == 10) print_string(25, 15, "Initializing VGA driver...", VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
        if (i == 15) print_string(25, 16, "Setting up memory manager...", VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
        if (i == 20) print_string(25, 17, "Starting system services...", VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
        if (i == 25) print_string(25, 18, "Boot complete!", VGA_COLOR_GREEN, VGA_COLOR_BLACK);
        
        // Délai pour l'animation
        for (volatile int j = 0; j < 10000000; j++);
    }
    
    // Attendre un moment puis passer à l'écran principal
    for (volatile int i = 0; i < 30000000; i++);
}

void kernel_main(uint32_t magic, uint32_t* mbi_addr) {
    if (magic != 0x2BADB002) {
        volatile uint16_t* vga = (volatile uint16_t*)0xB8000;
        const char* error = "BOOT ERROR: Invalid multiboot magic!";
        for (int i = 0; error[i]; i++) {
            vga[i] = 0x0C00 | error[i];
        }
        while(1);
    }
    
    // Séquence de boot
    show_loading();
    
    // Écran d'accueil principal
    draw_welcome_screen();
    
    // Attendre une interaction utilisateur
    wait_for_key();

    desktop_environment();
    
    while(1) {

        // Ici vous pouvez ajouter la gestion des commandes
    }
}