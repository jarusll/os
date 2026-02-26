BITS 16

ORG 0x7C00

SECTION .text

GLOBAL _start

_start:
    mov ah, 0x00
    mov al, 2
    int 0x10

    times 510-($-$$) db 0
    dw 0xAA55
