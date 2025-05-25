HOME_DIR := $(HOME)/BeckerOS
BOOTLOADER_SRC := $(HOME_DIR)/src/Bootloader.asm
BOOTLOADER_BIN := $(HOME_DIR)/bin/Bootloader.bin

OS_NAME = BeckerOS
ISO_OUTPUT = $(OS_NAME).iso

all: build-bin

build-bin:
	nasm -f bin $(BOOTLOADER_SRC) -o $(BOOTLOADER_BIN)

build-iso: build-bin
	mkisofs -o $(ISO_OUTPUT) -V "$(OS_NAME)" \
		-b bin/Bootloader.bin -no-emul-boot -boot-load-size 4 -boot-info-table \
		$(HOME_DIR)

run: build-iso
	qemu-system-x86_64 -cdrom $(ISO_OUTPUT)