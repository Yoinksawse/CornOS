HOME_DIR := .
OS_NAME := BeckerOS
ISO_OUTPUT := $(OS_NAME).iso

BOOT_SRC := $(HOME_DIR)/src/bootloader/boot.asm
BOOT_BIN := $(HOME_DIR)/bin/boot.bin
LOADER_SRC := $(HOME_DIR)/src/bootloader/loader.asm
LOADER_OBJ := $(HOME_DIR)/bin/loader.o

KERNEL_SRC := $(HOME_DIR)/src/kernel/kernel.c
KERNEL_OBJ := $(HOME_DIR)/bin/kernel.o
KERNEL_ELF := $(HOME_DIR)/bin/kernel.elf
KERNEL_BIN := $(HOME_DIR)/bin/kernel.bin

all: bootloader kernel iso clean
	qemu-system-i386 -cdrom $(ISO_OUTPUT) -boot d -m 512

test: bootloader
	qemu-system-i386 -fda bin/boot.bin -boot a -m 512

bootloader:
	nasm -f bin $(BOOT_SRC) -o $(BOOT_BIN)
	nasm -f elf32 -g $(LOADER_SRC) -o $(LOADER_OBJ)

kernel: bootloader linker.ld
	i686-elf-gcc -ffreestanding -nostdlib -m32 -c $(KERNEL_SRC) -o $(KERNEL_OBJ) 
	i686-elf-ld -T ./linker.ld -o $(KERNEL_ELF) $(LOADER_OBJ) $(KERNEL_OBJ)
	i686-elf-objcopy -O binary $(KERNEL_ELF) $(KERNEL_BIN)

iso: kernel
	cp bin/boot.bin .  
	mkisofs -o $(ISO_OUTPUT) -V "$(OS_NAME)" \
		-b boot.bin -no-emul-boot -boot-load-size 4 -boot-info-table \
		bin
	rm boot.bin
clean:
	rm -f $(BOOT_BIN) $(LOADER_OBJ) $(KERNEL_OBJ) $(KERNEL_ELF) $(KERNEL_BIN)


.PHONY: all bootloader kernel iso clean test