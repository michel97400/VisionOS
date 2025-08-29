# Makefile

# Définition des outils de compilation et de liaison
AS = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy

# Options de compilation et d'édition de liens
ASFLAGS_BOOT = -f bin
ASFLAGS_KERNEL_ENTRY = -f elf32
CFLAGS = -m32 -ffreestanding -O2 -nostdlib -nostdinc -fno-stack-protector -fno-pie
LDFLAGS = -melf_i386 -T linker.ld
KERNEL_ENTRY_OBJ = kernel_entry.o
KERNEL_OBJ = kernel.o
BOOTLOADER_OBJ = boot.o
KERNEL_BIN_ELF = kernel.bin.elf
KERNEL_BIN = kernel.bin
OS_IMG = os.img

# Règles de compilation
.PHONY: all clean

# La cible par défaut, qui crée l'image disque
all: $(OS_IMG)

# Règle pour compiler le bootloader
$(BOOTLOADER_OBJ): boot.asm
	$(AS) $(ASFLAGS_BOOT) $< -o $@

# Règle pour compiler l'entrée du noyau en assembleur
$(KERNEL_ENTRY_OBJ): kernel_entry.s
	$(AS) $(ASFLAGS_KERNEL_ENTRY) $< -o $@

# Règle pour compiler le fichier C en un fichier objet
$(KERNEL_OBJ): kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

# Lie les fichiers objets pour créer l'exécutable ELF
$(KERNEL_BIN_ELF): $(KERNEL_ENTRY_OBJ) $(KERNEL_OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

# Règle pour convertir le fichier ELF en binaire brut
$(KERNEL_BIN): $(KERNEL_BIN_ELF)
	$(OBJCOPY) -O binary $< $@

# Crée l'image disque
$(OS_IMG): $(BOOTLOADER_OBJ) $(KERNEL_BIN)
	dd if=/dev/zero of=$(OS_IMG) bs=512 count=2880
	dd if=$(BOOTLOADER_OBJ) of=$(OS_IMG) conv=notrunc
	dd if=$(KERNEL_BIN) of=$(OS_IMG) seek=1 conv=notrunc

# Règle pour nettoyer les fichiers générés
clean:
	rm -f $(BOOTLOADER_OBJ) $(KERNEL_ENTRY_OBJ) $(KERNEL_OBJ) $(KERNEL_BIN_ELF) $(KERNEL_BIN) $(OS_IMG)
