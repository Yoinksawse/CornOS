HOME_DIR := .
OS_NAME := BeckerOS
ISO_OUTPUT := $(OS_NAME).iso

BOOT_SRC := $(HOME_DIR)/src/bootloader/boot.asm
BOOT_BIN := $(HOME_DIR)/bin/boot.bin
LOADER_SRC := $(HOME_DIR)/src/bootloader/loader.asm
LOADER_OBJ := $(HOME_DIR)/bin/loader.o

KERNEL_SRC := $(HOME_DIR)/src/kernel/kernel_main.c
KERNEL_OBJ := $(HOME_DIR)/bin/kernel_main.o
KERNEL_ELF := $(HOME_DIR)/bin/kernel_main.elf
KERNEL_BIN := $(HOME_DIR)/bin/kernel_main.bin

all: bootloader kernel floppy_img clean
	qemu-system-i386 -cdrom $(ISO_OUTPUT) -boot d -m 512

test: bootloader
	qemu-system-i386 -fda bin/boot.bin -boot a -m 512

bootloader:
	nasm -f bin $(BOOT_SRC) -o $(BOOT_BIN)
	nasm -f elf32 $(LOADER_SRC) -o $(LOADER_OBJ)

kernel: bootloader 
	i686-elf-gcc -ffreestanding -m32 -c $(KERNEL_SRC) -o $(KERNEL_OBJ) 
	i686-elf-ld -Ttext 0xA000 -o $(KERNEL_ELF) $(LOADER_OBJ) $(KERNEL_OBJ)
	i686-elf-objcopy -O binary $(KERNEL_ELF) $(KERNEL_BIN)

floppy_img: 
	cp bin/boot.bin .  
	mkisofs -o $(ISO_OUTPUT) -V "$(OS_NAME)" \
		-b boot.bin -no-emul-boot -boot-load-size 4 -boot-info-table \
		bin
	rm boot.bin
clean:
	rm -f $(BOOT_BIN) $(LOADER_OBJ) $(KERNEL_OBJ) $(KERNEL_ELF) $(KERNEL_BIN)