#include "keyboard.h"

#define KEYBOARD_PORT 0x60

static char key_buffer = 0;
static uint8_t last_scancode = 0;

static char scancode_to_ascii_map[128] = {
    0, 27, '1','2','3','4','5','6','7','8','9','0','-','=', '\b',
    '\t','q','w','e','r','t','y','u','i','o','p','[',']','\n',0,
    'a','s','d','f','g','h','j','k','l',';','\'','`',0,'\\',
    'z','x','c','v','b','n','m',',','.','/',0, '*',0, ' ',0
};

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

void keyboard_init() {
    key_buffer = 0;
    last_scancode = 0;
}

void keyboard_update() {
    uint8_t scancode = inb(KEYBOARD_PORT);

    // Ignore scancode = 0 et break codes
    if (scancode == 0 || (scancode & 0x80)) {
        last_scancode = 0; // reset après release
        key_buffer = 0;
        return;
    }

    // Si c’est la même touche qu’avant, on ignore
    if (scancode == last_scancode) {
        key_buffer = 0;
        return;
    }

    last_scancode = scancode; // mémoriser la touche
    if (scancode < 128) key_buffer = scancode_to_ascii_map[scancode];
}

char keyboard_get_char() {
    char c = key_buffer;
    key_buffer = 0; // vider le buffer après lecture
    return c;
}
