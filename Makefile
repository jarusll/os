BUILD_DIR = build
GCC_FLAGS = -m16 -ffreestanding -nostdlib -nostartfiles -fno-builtin -nodefaultlibs -std=gnu11 -fno-pic -fno-stack-protector -masm=intel -g
LD_FLAGS = -m elf_i386 -nostdlib -T kernel/link.ld
ASM_FLAGS = -S -masm=intel

.PHONY: all clean floppy

all: clean $(BUILD_DIR)/floppy.img

clean:
	rm -rf $(BUILD_DIR)

$(BUILD_DIR)/floppy.img: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=$(BUILD_DIR)/boot.bin of=$@ conv=notrunc
	dd if=$(BUILD_DIR)/kernel.bin of=$@ bs=512 seek=1 conv=notrunc

$(BUILD_DIR)/boot.bin: boot/boot.asm
	mkdir -p $(BUILD_DIR)
	nasm -f bin boot/boot.asm -o $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/kernel.bin: kernel/kernel.c
	mkdir -p $(BUILD_DIR)
	gcc $(ASM_FLAGS) kernel/kernel.c -o $(BUILD_DIR)/kernel.lst
	gcc $(GCC_FLAGS) -c kernel/kernel.c -o $(BUILD_DIR)/kernel.o
	ld $(LD_FLAGS) $(BUILD_DIR)/kernel.o -o $(BUILD_DIR)/kernel.elf
	objcopy -O binary $(BUILD_DIR)/kernel.elf $(BUILD_DIR)/kernel.bin

start: all
	qemu-system-i386 \
		-drive file=$(BUILD_DIR)/floppy.img,index=0,if=floppy,format=raw
