BITS 16

ORG 0x7C00

%define VIDEO_INT 0x10
%define DISK_INT  0x13
%define KERNEL_ADDR 0x1000
%define STACK_ADDR 0x9000
%define NEW_LINE 0x0A

SECTION .text

GLOBAL _start

_start:
    ; SETUP SEGMENTS
    mov ax, 0
    mov ds, ax
    mov es, ax
    cld
    ; temp disable interrupts because bios uses stack
    cli
    mov ax, STACK_ADDR
    mov ss, ax
    mov sp, 0xFFFE
    sti

    ; SETUP VIDEO MODE
    ; set video mode to text 80x25
    mov ah, 0x00
    mov al, 3
    int VIDEO_INT

    ; PROBE the floppy
    ; reset the current floppy
    mov ah, 0x00
    mov dl, 0x00
    int DISK_INT
    jc reset_error

    ; LOAD SECOND SECTOR TO 0:1000
    mov ah, 0x02
    mov dl, 0x00 ; first floppy
    ; LBA 1 = CHS 0, 0, 2
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov al, 1 ; read 1 sector ie 512b
    ; read to es:bx
    mov bx, KERNEL_ADDR
    int DISK_INT

    jc read_error

    mov si, all_ok_msg
    call puts

    jmp 0:KERNEL_ADDR

reset_error:
    mov si, disk_error_msg
    call puts
    jmp halt

read_error:
    mov si, read_error_msg
    call puts

    push ax
    call puthex
    pop ax

    jmp halt

puts:
    push bp
    mov bp, sp

loop_puts:
    lodsb
    test al, al
    jz end_puts

    push ax
    call putc
    pop ax

    jmp loop_puts

end_puts:
    pop bp
    ret

putc:
    push bp
    mov bp, sp

    ; write char
    mov ah, 0x0E
    mov al, [bp + 4]
    int VIDEO_INT

    pop bp
    ret

putx:
    push bp
    mov bp, sp

    mov ax, word [bp + 4]
    cmp ax, 10
    jge alpha_char
    add ax, 48
    jmp putxc

alpha_char:
    add ax, 55

putxc:
    push ax
    call putc
    pop ax

    pop bp
    ret

puthex:
    push bp
    mov bp, sp

    mov ax, 1111000000000000b
    and ax, [bp + 4]
    shr ax, 12
    push ax
    call putx
    pop ax

    mov ax, 0000111100000000b
    and ax, [bp + 4]
    shr ax, 8
    push ax
    call putx
    pop ax

    mov ax, 0000000011110000b
    and ax, [bp + 4]
    shr ax, 4
    push ax
    call putx
    pop ax

    mov ax, 0000000000001111b
    and ax, [bp + 4]
    push ax
    call putx
    pop ax

    push NEW_LINE
    call putc
    pop ax

    pop bp
    ret

halt:
    jmp halt


all_ok_msg: db "ALL OK", NEW_LINE, 0
disk_error_msg: db "DISK ERROR", NEW_LINE,0
read_error_msg: db "READ ERROR", NEW_LINE, 0

    ; padding
    times 510-($-$$) db 0
    dw 0xAA55
