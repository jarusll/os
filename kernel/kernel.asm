BITS 16

ORG 0x1000

SECTION .text

GLOBAL _start

_start:
    ; set up cursor
    mov ah, 0x02
    mov dh, 10
    mov dl, 10
    mov bh, 0
    int 0x10

    ; write A
    mov ah, 0x09
    mov bh, 0
    mov cx, 1
    mov bl, 0x0F
    mov al, 'A'
    int 0x10

halt:
    jmp halt
