BUILD_DIR = build
GCC_FLAGS = -m16 -ffreestanding -masm=intel -ggdb -nostdlib
GCC_64_FLAGS = -m64 -ffreestanding -masm=intel -ggdb -nostdlib
LD_FLAGS = -nostdlib -T kernel/link.ld
ASM_FLAGS = -S -masm=intel
GCC_64=gcc
LD_64=ld
GCC=~/opt/cross/bin/i686-elf-gcc
LD=~/opt/cross/bin/i686-elf-ld
MNT_DIR=./mnt

.PHONY: all clean floppy

all: clean $(BUILD_DIR)/os.img

clean:
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	-sudo umount $(MNT_DIR) || true
	rm -rf $(MNT_DIR)
	mkdir -p $(MNT_DIR)/boot/limine

$(BUILD_DIR)/os.img: $(BUILD_DIR)/kernel.elf
	dd if=/dev/zero of=$@ bs=1M count=64
	limine bios-install $@
	/sbin/mkfs.ext2 $@
	sudo mount $@ $(MNT_DIR)
	mkdir -p $(MNT_DIR)/boot/limine
	cp $(BUILD_DIR)/kernel.elf $(MNT_DIR)/boot/.
	cp limine/limine-bios.sys $(MNT_DIR)/boot/limine/.
	cp limine/limine.cfg $(MNT_DIR)/boot/limine/.
	sudo umount $(MNT_DIR)

$(BUILD_DIR)/kernel.elf: $(BUILD_DIR)/kernel.o
	$(LD_64) $(LD_FLAGS) $(BUILD_DIR)/kernel.o -o $@

$(BUILD_DIR)/kernel.o: kernel/kernel.limine.c
	$(GCC_64) $(GCC_64_FLAGS) -c kernel/kernel.limine.c -o $@

$(BUILD_DIR)/kernel.lst: kernel/kernel.limine.c
	$(GCC_64) $(ASM_FLAGS) kernel/kernel.limine.c -o $@





$(BUILD_DIR)/floppy.img: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=$(BUILD_DIR)/boot.bin of=$@ conv=notrunc
	dd if=$(BUILD_DIR)/kernel.bin of=$@ bs=512 seek=1 conv=notrunc

$(BUILD_DIR)/boot.bin: boot/boot.asm
	mkdir -p $(BUILD_DIR)
	nasm -f bin boot/boot.asm -o $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/kernel.bin: kernel/kernel.c
	mkdir -p $(BUILD_DIR)
	$(GCC) $(ASM_FLAGS) kernel/kernel.c -o $(BUILD_DIR)/kernel.lst
	$(GCC) $(GCC_FLAGS) -c kernel/kernel.c -o $(BUILD_DIR)/kernel.o
	$(LD) $(LD_FLAGS) $(BUILD_DIR)/kernel.o -o $(BUILD_DIR)/kernel.elf
	objcopy -O binary $(BUILD_DIR)/kernel.elf $(BUILD_DIR)/kernel.bin

start: all
	qemu-system-i386 \
		-drive file=$(BUILD_DIR)/floppy.img,index=0,if=floppy,format=raw
