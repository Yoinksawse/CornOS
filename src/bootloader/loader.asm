;stage 2 of booting: load kernel.elf + jump to entry point
;KERNEL STARTS AT 0x10000
[bits 32]

global _start:
extern kernel_main

_start:
    call kernel_main
    jmp $

times 512 - ($ - $$) db 0