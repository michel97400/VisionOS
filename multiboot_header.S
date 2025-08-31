# Section multiboot DOIT être la première !
.section .multiboot.header, "a"
.align 4

# Header Multiboot (DOIT être dans les premiers 8192 bytes)
multiboot_header:
    .long 0x1BADB002      # magic number
    .long 0x00000003      # flags (PAGE_ALIGN | MEMORY_INFO)  
    .long -(0x1BADB002 + 0x00000003)  # checksum

.section .multiboot.text, "ax"
.global _start

_start:
    # Stack setup
    mov $stack_top, %esp
    
    # Push multiboot info pointer
    push %ebx
    push %eax    # magic number pour vérification
    
    # Appel du kernel
    call kernel_main
    
    # Si on revient ici, boucle infinie
    cli
halt_loop:
    hlt
    jmp halt_loop

# Stack pour le kernel (4KB)
.section .bss
.align 16
stack_bottom:
    .skip 4096
stack_top: