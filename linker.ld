ENTRY(_start)

SECTIONS
{
    . = 1M;

    /* Section multiboot DOIT être la première et dans les 8KB */
    .multiboot : ALIGN(4K)
    {
        KEEP(*(.multiboot.header))
    }

    .text : ALIGN(4K)  
    {
        *(.multiboot.text)
        *(.text)
        *(.text.*)
    }

    .rodata : ALIGN(4K)
    {
        *(.rodata)
        *(.rodata.*)
    }

    .data : ALIGN(4K)
    {
        *(.data)
        *(.data.*)
    }

    .bss : ALIGN(4K)
    {
        *(COMMON)
        *(.bss)
        *(.bss.*)
    }
}