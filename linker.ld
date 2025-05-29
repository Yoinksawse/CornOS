ENTRY(_ldr_start)    /*starting point of kernel*/
OUTPUT_FORMAT(binary)

SECTIONS {
    . = 0x100000;   /*kernel here*/

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
