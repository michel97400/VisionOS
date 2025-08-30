#include <stdint.h>

#define MULTIBOOT_HEADER_MAGIC    0x1BADB002
#define MULTIBOOT_HEADER_FLAGS    0x0
#define MULTIBOOT_CHECKSUM        -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

__attribute__((section(".multiboot")))
const uint32_t multiboot_header[] = {
    MULTIBOOT_HEADER_MAGIC,
    MULTIBOOT_HEADER_FLAGS,
    MULTIBOOT_CHECKSUM
};

uint16_t* video_memory = (uint16_t*)0xB8000;
int cursor_x = 0;
int cursor_y = 0;

void put_char(char c, uint8_t color) {
    if (c == '\n') { cursor_x = 0; cursor_y++; return; }
    video_memory[cursor_y * 80 + cursor_x] = (color << 8) | c;
    cursor_x++;
    if (cursor_x >= 80) { cursor_x = 0; cursor_y++; }
}

void print(const char* str) {
    while (*str) { put_char(*str, 0x07); str++; }
}

void kernel_main() {
    print("Hello, noyau minimal avec GRUB et multiboot !\n");
    while(1) {}
}
