ENTRY(_ldr_start)
OUTPUT_FORMAT(binary)

SECTIONS {
    . = 0xA000;   /*kernel here*/

    .text : ALIGN(4096) {
        *(.text)
    }

    .rodata : ALIGN(4096) {
        *(.rodata)
    }

    .data : ALIGN(4096) {
        *(.data)
    }

    .bss : ALIGN(4096) {
        *(.bss COMMON)
    }
}