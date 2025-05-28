;stage 1 of booting
;-real mode: 
;-protected mode: run Loader (loads kernel elf)
;================================16-bit real mode==============================================
;clear registers, disable interrupts, (enable a20line), load gdt

[bits 16] 
[org 0x7C00]

start:
    cli                             ;clear interrupt flags + disable
    mov ax, 0x00                    ;clear used registers
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00 - 0x100          ;setup stack below bootloader 
    sti                             ;enable interrupts
    
    mov si, msg
    call print
end:
    cli                             ;clear interrupts
    hlt                             ;halt cpu work


;BEGIN TELETYPE PRINT FUNCTION (Fooling around)
print:                              ;print: parameter is string in si
    push si                         ;record current data
    push ax
looper:
    lodsb                           ;loads next byte in si to al, si++
    or al, al                       ;return if null
    jz .done
    mov ah, 0x0E                    ;teletype output
    int 0x10                        ;bios interrupt print
    jmp looper                      ;loop
.done:
    pop ax
    pop si
    ret
;END TELETYPE PRINT FUNCTION

;==============================entering protected mode=========================================
mov eax, cr0                        ;make cr0 := 1 := protected mode
or eax, 1
mov cr0, eax

;=============================32-bit protected mode============================================
;run Loader (REMEMBER: KERNEL MUST START AT 0xA000), 
[bits 32]



;=============================data segment=====================================================
;BEGIN GDT BEGIN GDT BEGIN GDT BEGIN GDT
gdt_start:
    ;null Segment
    gdt_null:
        dq 0

    ;Kernel (DPL 0) Only Code Segment 
    ;limit: 0xfffff
    ;base: 0x00000000
    gdt_code:
        dw 0xffff           ;limit (part 1)
        dw 0x0000           ;base (part 1)
        db 0x00             ;base (part 2)
        db 10011010b        ;access byte: (1)(00: DPL, 2bi)(1: CS)(1: CS)(0: CS, only DPL0)(1: RW)(0: not accessed)
        db 11001111b        ;limit (part 2): 0fh = 1111b (first nibble), \
                            ;flags: (1: page granularity)(1: 32 bit segment)(0: clear)(0: reserved) (second nibble)
        db 0x00             ;base (part 3)

    ;Kernel Mode Data System Segment 
    ;limit: 0xfffff
    ;base: 0x00000000
    gdt_data:
        dw 0xffff           ;limit (part 1)
        dw 0x0000           ;base (part 1)
        db 0x00             ;base (part 2)
        db 10010010b        ;access byte: (1)(00: DPL 0)(1: DS)(0: DS)(0: grows up)(1: RW)(0: not accessed)
        db 11001111b        ;limit (part 2): 0fh = 1111b (first nibble), \
                            ;flags: (1: page granularity)(1: 32 bit segment)(0: clear)(0: reserved) (second nibble)
        db 0x00             ;base (part 3)
    
    ;Task State System Segment 
    ;base: start of tss / 0
    ;limit: size - 1 = 104 - 1 bits
    tss: resb 104
    gdt_taskstate:
        dw 104 - 1          ;limit (part 1)
        dw tss              ;base (part 1)
        db 0x00             ;base (part 2)
        db 10001001b        ;access byte: (1)(00: DPL 0)(0: tss segment)(0x9/1001b: 32bi tss, available)
        db 00000000b        ;limit (part 2): 0000 (first nibble), \
                            ;flags: (0: byte granularity)(0: irrelevant for tss)(0: clear)(0: reserved) (second nibble)
        db 0x00             ;base (part 3)
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1      ; length = size - 1 (limit)
    dd gdt_start                    ; base address
;END GDT END GDT END GDT END GDT END GDT

msg db 'Booting...', 0              ;print message (null at end)

times 510 - ($ - $$) db 0           ;memset remaining of 1st segment to 0
dw 0xaa55                           ;last 2 bytes: MBR signature