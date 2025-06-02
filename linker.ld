ENTRY(kmain)
OUTPUT_FORMAT(binary)

SECTIONS {
    . = 0x100000;   /* Load address from bootloader */

    .text : {
        *(.text)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss COMMON)
    }
}
