;stage 1 of booting: 
;-real mode: clear registers, disable interrupts, (enable a20line), load gdt
;-protected mode: run Loader (loads kernel elf)
;Whether the CPU is in Real Mode or in Protected Mode is defined by the lowest bit of the CR0 or MSW register


;implement ELF parsing functionality. This involves reading the ELF headers, 
;loading the specified sections into memory, and jumping to the entry point defined in the ELF file.????



[bits 16] ;real mode
[org 0x7c00]

section .text
    global _start
_start:
    hlt

.halt:
    jmp .halt



[bits 32] ;protected mode


times 510-($-$$) db 0
dw 0x55AA