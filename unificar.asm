; unificar.asm
[org 0x7C00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov al, 0x13
    int 0x10        ; modo gráfico 320x200x256

    ; Cargar sector 2 en 0x0000:0x7E00
    mov ah, 0x02
    mov al, 1         ; Leer 1 sector
    mov ch, 0
    mov cl, 2         ; sector físico 2
    mov dh, 0
    mov dl, 0x00
    mov bx, 0x7E00    ; offset
    int 0x13
    jc error

    jmp 0x0000:0x7E00 ; saltar a la rutina de sector 2

error:
    jmp $

times 510 - ($ - $$) db 0
dw 0xAA55
