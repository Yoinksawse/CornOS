;kernel loader: SKIPPED
;KERNEL STARTS AT 0xA000
[bits 32]

section .text
    global _ldr_start:       ;entry point into kernel (accessed by booter)
    extern kmain             ;in kernel.c

_ldr_start:
    call kmain
    jmp $

times 512 - ($ - $$) db 0

;SKIPPED SECTION