# Nom du noyau
KERNEL = kernel
ISO_DIR = iso
ISO_BOOT = $(ISO_DIR)/boot
ISO_GRUB = $(ISO_BOOT)/grub

# Couleurs terminal
GREEN = \033[0;32m
NC = \033[0m

# Compilation
all: $(KERNEL).bin

$(KERNEL).o: $(KERNEL).c
	@echo -e "$(GREEN)Compilation de $(KERNEL).c...$(NC)"
	gcc -m32 -ffreestanding -c $< -o $@

$(KERNEL).bin: $(KERNEL).o linker.ld
	@echo -e "$(GREEN)Linking de $(KERNEL).bin...$(NC)"
	ld -m elf_i386 -T linker.ld -o $@ $<

# Nettoyage
clean:
	@echo -e "$(GREEN)Suppression des fichiers objets et binaires...$(NC)"
	rm -f $(KERNEL).o $(KERNEL).bin
	rm -rf $(ISO_DIR)

# Créer l'ISO bootable avec GRUB
iso: all
	@echo -e "$(GREEN)Création de l'ISO bootable...$(NC)"
	mkdir -p $(ISO_GRUB)
	cp $(KERNEL).bin $(ISO_BOOT)/
	cp grub.cfg $(ISO_GRUB)/
	grub-mkrescue -o $(KERNEL).iso $(ISO_DIR)

# Lancer le noyau dans QEMU
run: iso
	@echo -e "$(GREEN)Lancement dans QEMU...$(NC)"
	qemu-system-i386 -cdrom $(KERNEL).iso

.PHONY: all clean iso run
