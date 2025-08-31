KERNEL = kernel
OBJS = multiboot_header.o kernel.o keyboard.o

ISO_DIR = iso
ISO_BOOT = $(ISO_DIR)/boot
ISO_GRUB = $(ISO_BOOT)/grub

GREEN = \033[0;32m
NC = \033[0m

all: $(KERNEL).bin

# Compiler C
%.o: %.c
	@echo -e "$(GREEN)Compilation de $< ...$(NC)"
	gcc -m32 -ffreestanding -c $< -o $@

# Compiler assembleur
multiboot_header.o: multiboot_header.S
	@echo -e "$(GREEN)Compilation du header multiboot ...$(NC)"
	as --32 $< -o $@

# Linker
$(KERNEL).bin: $(OBJS) linker.ld
	@echo -e "$(GREEN)Linking de $(KERNEL).bin...$(NC)"
	ld -m elf_i386 -T linker.ld -o $@ $(OBJS)

# Nettoyage
clean:
	@echo -e "$(GREEN)Suppression des fichiers objets et binaires...$(NC)"
	rm -f $(OBJS) $(KERNEL).bin
	rm -rf $(ISO_DIR)
	rm -f $(KERNEL).iso

# ISO bootable
iso: all
	@echo -e "$(GREEN)Création de l'ISO bootable...$(NC)"
	mkdir -p $(ISO_GRUB)
	cp $(KERNEL).bin $(ISO_BOOT)/
	cp grub.cfg $(ISO_GRUB)/
	grub-mkrescue -o $(KERNEL).iso $(ISO_DIR)

# Lancer QEMU
run: iso
	@echo -e "$(GREEN)Lancement dans QEMU...$(NC)"
	qemu-system-i386 -cdrom $(KERNEL).iso

.PHONY: all clean iso run
