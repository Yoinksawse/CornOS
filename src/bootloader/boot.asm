;bootloader stage 1
;================================16-bit real mode==============================================
[bits 16] 
[org 0x7C00]

_start:
    cli                             ;clear interrupt flags + disable
    mov ax, 0x00                    ;clear used registers
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00 - 0x100          ;setup stack below bootloader 

    mov [hdd], dl                   ;remember boot drive for reading from disk later
    sti                             ;enable interrupts

;load raw kernel binary code from hard drive using CHS
load_kernel_from_disk:
    mov bx, kernel_start
    mov ch, 0x00                    ;Cylinder
    mov dh, 0x00                    ;Head
    mov cl, 0x02                    ;Sector
    mov dl, [hdd]                   ;read from 1st hdd
    mov ah, 0x02                    ;read
    mov al, 8                       ;totoal no of sectors (must match makefile iso generation command)
    int 0x13

;load vesa vbe info from bios when in 16 bit real mode
load_vesa_vbe:
    ;clear info block at 0x8000 (physical addr)
    mov ax, 0x0800
    mov es, ax
    xor di, di
    mov cx, 512
    xor ax, ax
    .clear_vbe_loop:
        stosw
        loop .clear_vbe_loop

    ;get vesa bios info
    mov ax, 0x4f01                  ;return vbe modes to es:di
    mov cx, 0x118                   ;video mode 118 (seems the best idk)
    xor dx, dx                      ;calc segment = 0x8000 >> 4
    mov dx, 0x0800
    mov es, dx
    xor di, di                      ;calc offset = 0
    int 0x10

    ;sets bios video mode, set linear framebuffer.
    mov ax, 0x4f02                  ;Bios function: sets 
    mov bx, 0x4118                  ;VBE MODE 0x118 (100011000b) + Linear Framebuffer (14th bit set)
    int 0x10

;------------------------------entering protected mode-----------------------------------------
goPMode:
    cli                             ;disable interrupts

    ;enable a20 address line (fast): 1mb + 64kb memory 
    in al, 0x92                     ;read config (1 byte) from port 0x92 (controls a20) to al
    or al, 2                        ;set bit 1 to 1: a20 enabled
    out 0x92, al                    ;output new config byte to 0x92

    ;loading gdt
    xor ax, ax
    mov ds, ax                      ;clear data segment for our own 
    lgdt [gdt_descriptor]           ;load gdt

    ;changing cpu mode
    mov eax, cr0                    ;make cr0 (cpu mode) := 1 := protected mode
    or eax, 1
    mov cr0, eax

    jmp code_seg:PModeMain          ;far jump to protected mode: setup cs

;=============================32-bit protected mode============================================
[bits 32]
PModeMain:
    mov ebp, 0x9c00                 ;setup base pointer 
    and ebp, 0xFFFFFFF0             ;trim last 4 bits (for long mode safety)

    ; Set segment registers
    mov ax, data_seg
    mov ds, ax                      ;setup data segment
    mov ss, ax                      ;setup stack segment (segment)
    mov esp, ebp                    ;setup stack pointer (offset)
    mov es, ax                      ;setup extra segment (si and di)
    mov fs, ax
    mov gs, ax

    ;init tss
    mov ax, taskstate_seg           ;load task state segment
    ltr ax                          ;to task tegister


    ;test_printing:
    ;    mov edi, 0xB8000                ;Video RAM memory area
    ;    mov esi, msg                    ;"Booted!"
    ;    mov ah, 0x8b                    ;attribute byte: bright cyan on black, blinking: change to 0x1b for more colours
    ;    .print_loop:
    ;        lodsb                       ;load [esi] to al, increment esi
    ;        test al, al                 ;check for null terminator
    ;        jz .goKernel
    ;        stosw                       ;store ax to edi, add 2 to esi
    ;    jmp .print_loop

    .goKernel: jmp code_seg:kernel_start       ;jump to start address of loader (stage 2 bootloader)

;=============================unlabelled data segment==========================================
;BEGIN GDT BEGIN GDT BEGIN GDT BEGIN GDT BEGIN GDT BEGIN GDT BEGIN GDT BEGIN GDT BEGIN GDT BEGIN GDT BEGIN GDT BEGIN GDT
gdt_start:
    ;Null Segment
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
    dw gdt_end - gdt_start - 1      ;length = size - 1 (limit)
    dd gdt_start                    ;base address

code_seg equ gdt_code - gdt_start
data_seg equ gdt_data - gdt_start
taskstate_seg equ gdt_taskstate - gdt_start
;END GDT END GDT END GDT END GDT END GDT END GDT END GDT END GDT END GDT END GDT END GDT END GDT END GDT END GDT END GDT

;loader, kernel info 
kernel_start equ 0xA000           ;kernel STARTS AT 0xA000

vbe_info_block equ 0x8000           ;vbe info block address = 0x8000 (MBR < 0x800 < loader + kernel)
hdd db 0                            ;bootdrive id
msg db 'Booted!', 0                 ;cute message
;==============================================================================================
times 510 - ($ - $$) db 0           ;memset remaining of 1st segment to 0
dw 0xaa55                           ;last 2 bytes: MBR signature