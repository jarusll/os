BITS 16

ORG 0x1000

%define VIDEO_INT 0x10
%define DISK_INT  0x13
%define KERNEL_ADDR 0x1000
%define STACK_ADDR 0x9000
%define NEW_LINE 0x0A
%define SYSTEM_INT 0x15

SECTION .text

GLOBAL _start

_start:
    ; SETUP VIDEO MODE 80x25
    mov ah, 0x00
    mov al, 3
    int VIDEO_INT

    ; ; extended memory size determine
    ; mov ah, 0x88
    ; int SYSTEM_INT

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
