BUILD_DIR = build

.PHONY: all clean floppy

all: $(BUILD_DIR)/floppy.img

$(BUILD_DIR)/floppy.img: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=$(BUILD_DIR)/boot.bin of=$@ conv=notrunc
	dd if=$(BUILD_DIR)/kernel.bin of=$@ bs=512 seek=1 conv=notrunc

$(BUILD_DIR)/boot.bin: boot/boot.asm
	mkdir -p $(BUILD_DIR)
	nasm -f bin boot/boot.asm -o $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/kernel.bin: kernel/kernel.asm
	mkdir -p $(BUILD_DIR)
	nasm -f bin kernel/kernel.asm -o $(BUILD_DIR)/kernel.bin

start: all
	qemu-system-i386 -fda $(BUILD_DIR)/floppy.img
