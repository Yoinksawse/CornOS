HOME_DIR := .
OS_NAME := CornOS
KERNEL_NAME := CornKernel
ISO_DIR := isobuild
ISO_OUTPUT := $(OS_NAME).iso
BIN_OUTPUT := $(HOME_DIR)/bin/$(OS_NAME).bin
IMG_OUTPUT := $(ISO_DIR)/$(OS_NAME).img
FLAGS := -g -ffreestanding -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

BOOT_SRC := $(HOME_DIR)/src/bootloader/boot.asm
BOOT_BIN := $(HOME_DIR)/bin/boot.bin

LOADER_SRC := $(HOME_DIR)/src/kernel/kernel_loader.asm
LOADER_OBJ := $(HOME_DIR)/bin/kernel_loader.o
KERNEL_SRC := $(HOME_DIR)/src/kernel/kernel.c
KERNEL_OBJ := $(HOME_DIR)/bin/kernel.o
KERNEL_ELF := $(HOME_DIR)/bin/kernel.elf
KERNEL_BIN := $(HOME_DIR)/bin/kernel.bin

COMPLETEKERNEL_OBJ := $(HOME_DIR)/bin/CornKernel.o

all: bootloader kernel bin iso clean
	#qemu-system-i386 -fda ./bin/$(OS_NAME).bin -S -gdb tcp::1234
	qemu-system-i386 -cdrom $(ISO_OUTPUT) -boot d -m 512


test-qemu: bin
	#SECOND TERMINAL, run this in new terminal first before test-gdb
	qemu-system-i386 -fda $(BIN_OUTPUT) -S -gdb tcp::1234
test-gdb: bin
	#FIRST TERMINAL, run test-qemu in new terminal before this
	gdb -q -x gdbscript.gdb < /dev/null


bootloader:
	nasm -f bin $(BOOT_SRC) -o $(BOOT_BIN)
	nasm -f elf32 -g $(LOADER_SRC) -o $(LOADER_OBJ)

kernel: bootloader
	#For 64-bit long mode
	#x86_64-elf-gcc -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -c $(KERNEL_SRC) -o $(KERNEL_OBJ)
	#x86_64-elf-gcc -ffreestanding -T ./linker.ld $(LOADER_OBJ) $(KERNEL_OBJ) -o $(KERNEL_ELF) -nostdlib -lgcc

	#for 32-bit protected mode (screeek version: idk how to build commands.)
	i686-elf-gcc -I./src $(FLAGS) -std=gnu99 -c $(KERNEL_SRC) -o $(KERNEL_OBJ)
	i686-elf-ld -g -relocatable $(LOADER_OBJ) $(KERNEL_OBJ) -o $(COMPLETEKERNEL_OBJ)
	i686-elf-gcc $(FLAGS) -T ./linker.ld -o $(KERNEL_BIN) -ffreestanding -O0 -nostdlib $(COMPLETEKERNEL_OBJ)
	
bin: kernel
	#dd if=$(BOOT_BIN) >> $(BIN_OUTPUT)
	#dd if=$(KERNEL_BIN) >> $(BIN_OUTPUT)
	#dd if=/dev/zero bs=512 count=8 >> $(BIN_OUTPUT)

	dd if=$(BOOT_BIN) of=$(BIN_OUTPUT) bs=512 count=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=$(BIN_OUTPUT) bs=512 seek=1 conv=notrunc
	dd if=/dev/zero of=$(BIN_OUTPUT) bs=512 seek=33 count=8 conv=notrunc

iso: kernel
	mkdir -p $(ISO_DIR)
	cp $(BIN_OUTPUT) $(IMG_OUTPUT)
	xorriso -as mkisofs -b $(OS_NAME).img \
		-no-emul-boot -boot-load-size 4 -boot-info-table -o $(ISO_OUTPUT) $(ISO_DIR)

clean:
	rm -f $(BOOT_BIN) $(LOADER_OBJ) $(KERNEL_OBJ) $(KERNEL_ELF) $(KERNEL_BIN) 