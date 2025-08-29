/* Le script de liaison (linker script) */
ENTRY(start)



SECTIONS
{
    /* Le noyau commence à l'adresse mémoire 1 Mo (0x8000) */
    . = 0x8000;

    .text :
    {
        /* Le code exécutable se trouve ici. Le '.' représente l'adresse courante. */
        *(.text)
    }

    .data :
    {
        /* Les données initialisées et les variables globales vont ici. */
        *(.data)
    }

    .bss :
    {
        /* Les données non initialisées (comme les tableaux ou les variables globales sans valeur) vont ici. */
        *(.bss)
    }
}