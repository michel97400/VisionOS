ENTRY(kernel_main)
SECTIONS
{
    . = 0x100000;   /* adresse où le noyau sera chargé par GRUB */

    .text :
    {
        *(.text)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(.bss)
        *(COMMON)
    }
}
