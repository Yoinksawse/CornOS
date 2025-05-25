HOME_DIR := $(HOME)/BeckerOS
OS_NAME := BeckerOS
ISO_OUTPUT := $(OS_NAME).iso

BOOT_SRC := $(HOME_DIR)/src/Boot.asm
BOOT_BIN := $(HOME_DIR)/bin/Boot.bin
LOADER_SRC := $(HOME_DIR)/src/Loader.asm
LOADER_OBJ := $(HOME_DIR)/bin/Loader.o

KERNEL_SRC := $(HOME_DIR)/src/kernel_main.c
KERNEL_OBJ := $(HOME_DIR)/bin/kernel_main.o
KERNEL_ELF := $(HOME_DIR)/bin/kernel_main.elf
KERNEL_BIN := $(HOME_DIR)/bin/kernel_main.bin

all: build-BootLoader build-kernel build-iso run clean

build-BootLoader:
	nasm -f bin $(BOOT_SRC) -o $(BOOT_BIN)
	nasm -f elf32 $(LOADER_SRC) -o $(LOADER_OBJ)

build-kernel: build-BootLoader 
	i686-elf-gcc -ffreestanding -m32 -c $(KERNEL_SRC) -o $(KERNEL_OBJ) 
	i686-elf-ld -Ttext 0xA000 -o $(KERNEL_ELF) $(LOADER_OBJ) $(KERNEL_OBJ)
	i686-elf-objcopy -O binary $(KERNEL_ELF) $(KERNEL_BIN)

build-iso: build-kernel
	mkisofs -o $(ISO_OUTPUT) -V "$(OS_NAME)" \
		-b bin/Boot.bin -no-emul-boot -boot-load-size 4 -boot-info-table \
		$(HOME_DIR)

run: build-iso
	qemu-system-x86_64 -cdrom $(ISO_OUTPUT)

clean:
	rm -f $(BOOT_BIN) $(LOADER_OBJ) $(KERNEL_OBJ) $(KERNEL_ELF) $(KERNEL_BIN)