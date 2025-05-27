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
print:                          ;print: parameter is string in si
    push si                     ;record current data
    push ax
looper:
    lodsb                       ;loads next byte in si to al, si++
    or al, al                   ;return if null
    jz .done
    mov ah, 0x0E                ;teletype output
    int 0x10                    ;bios interrupt print
    jmp looper                   ;loop
.done:
    pop ax
    pop si
    ret
;END TELETYPE PRINT FUNCTION
;==============================entering protected mode=========================================

;CPU mode is determined by bit 0 of cr0: 0 = real Mode, 1 = Protected Mode 
mov eax, cr0 ;make cr0 become 1
or eax, 1
mov cr0, eax

;=============================32-bit protected mode============================================
;run Loader (loads kernel elf), 
;[bits 32]



;=============================data segment=====================================================
msg db 'Booting...', 0              ;print message (null at end)

times 510 - ($ - $$) db 0           ;memset remaining of 1st segment to 0
dw 0xaa55                           ;last 2 bytes: MBR signature