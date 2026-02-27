BITS 16

ORG 0x7C00

SECTION .text

GLOBAL _start

_start:
    ; SETUP SEGMENTS
    mov ax, 0
    mov ds, ax
    ; temp disable interrupts because bios uses stack
    cli
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0
    sti

    ; set video mode to text 80x25
    mov ah, 0x00
    mov al, 2
    int 0x10

    ; LOAD SECOND SECTOR TO 0:1000
    mov ah, 0x02
    mov dl, 0x00 ; first floppy
    ; LBA 1 = CHS 0, 0, 2
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov al, 1 ; read 1 sector
    ; read to es:bx
    mov ax, 0x1000
    mov es, ax
    mov bx, 0
    int 0x13

    jc print_read_error

    jmp 0x1000:0

print_read_error:
    push all_ok
    call puts
    pop ax
    jmp halt

puts:
    push bp
    mov bp, sp

    mov si, [bp + 4] ; setup ds:si

loop_puts:
    lodsb
    jz end_puts

    ; write char
    mov ah, 0x0E
    int 0x10
    ; mov bh, 0
    ; mov cx, 1
    ; mov bl, 0x0F
    ; char in al
    ; mov bl, 0x0F

    jmp loop_puts

end_puts:
    pop bp
    ret

halt:
    jmp halt

all_ok: db "ALL OK", 0

    ; padding
    times 510-($-$$) db 0
    dw 0xAA55
