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

KMAIN_SRC := $(HOME_DIR)/src/kernel/kernel.c
KMAIN_OBJ := $(HOME_DIR)/bin/kernel.o
KMAIN_BIN := $(HOME_DIR)/bin/kernel.bin
INPUT_SRC := $(HOME_DIR)/src/kernel/input.c
INPUT_OBJ := $(HOME_DIR)/bin/input.o
OUTPUT_SRC := $(HOME_DIR)/src/kernel/output.c
OUTPUT_OBJ := $(HOME_DIR)/bin/output.o
MYLIB_SRC := $(HOME_DIR)/src/kernel/mylib.c
MYLIB_OBJ := $(HOME_DIR)/bin/mylib.o

FULLCORNKERNEL_OBJ := $(HOME_DIR)/bin/CornKernel.o

all: bootloader kernel bin iso clean
	#qemu-system-i386 -fda ./bin/$(OS_NAME).bin -S -gdb tcp::1234
	qemu-system-i386 -cdrom $(ISO_OUTPUT) -boot d -m 512

test: bin
	qemu-system-i386 -fda $(BIN_OUTPUT) -serial stdio
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
	#x86_64-elf-gcc -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -c $(KMAIN_SRC) -o $(KMAIN_OBJ)
	#x86_64-elf-gcc -ffreestanding -T ./linker.ld $(LOADER_OBJ) $(KMAIN_OBJ) -o $(KMAIN_ELF) -nostdlib -lgcc

	#for 32-bit protected mode: INCLUDE ALL NECESSARY FILES
	i686-elf-gcc -I./src $(FLAGS) -std=gnu99 -c $(KMAIN_SRC) -o $(KMAIN_OBJ) 
	i686-elf-gcc -I./src $(FLAGS) -std=gnu99 -c $(OUTPUT_SRC) -o $(OUTPUT_OBJ) 
	i686-elf-gcc -I./src $(FLAGS) -std=gnu99 -c $(MYLIB_SRC) -o $(MYLIB_OBJ) 
	i686-elf-ld -g -relocatable $(LOADER_OBJ) $(KMAIN_OBJ) $(OUTPUT_OBJ) $(MYLIB_OBJ) -o $(FULLCORNKERNEL_OBJ) 
	#linking
	i686-elf-gcc $(FLAGS) -T ./linker.ld -o $(KMAIN_BIN) -ffreestanding -O0 -nostdlib $(FULLCORNKERNEL_OBJ)
	
bin: kernel
	dd if=$(BOOT_BIN) of=$(BIN_OUTPUT) bs=512 count=1 conv=notrunc
	dd if=$(KMAIN_BIN) of=$(BIN_OUTPUT) bs=512 seek=1 conv=notrunc
	dd if=/dev/zero of=$(BIN_OUTPUT) bs=512 seek=33 count=8 conv=notrunc

iso: kernel
	mkdir -p $(ISO_DIR)
	cp $(BIN_OUTPUT) $(IMG_OUTPUT)
	xorriso -as mkisofs -b $(OS_NAME).img \
		-no-emul-boot -boot-load-size 4 -boot-info-table -o $(ISO_OUTPUT) $(ISO_DIR)

clean:
	rm -f $(BOOT_BIN) $(LOADER_OBJ) $(KMAIN_OBJ) $(KMAIN_ELF) $(KMAIN_BIN) $(MYLIB_OBJ) $(OUTPUT_OBJ) $(FULLCORNKERNEL_OBJ) $(BIN_OUTPUT)