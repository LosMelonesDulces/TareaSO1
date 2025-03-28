[org 0x7C00]
[bits 16]

    ; --- Inicialización ---
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; Stack justo debajo del MBR

    ; --- Modo Video 13h ---
    mov ax, 0x0013
    int 0x10

    ; --- Cargar square.asm en 0x7E00 (1 sector = 512 bytes) ---
    mov ax, 0x0000
    mov es, ax          ; ES = 0x0000 (segmento)
    mov bx, 0x7E00      ; ES:BX = 0x0000:7E00 (destino)
    mov ah, 0x02        ; Función de lectura de disco
    mov al, 1           ; 1 sector (512 bytes)
    mov ch, 0           ; Cilindro 0
    mov dh, 0           ; Cabeza 0
    mov cl, 2           ; Sector 2 (el MBR está en el sector 1)
    int 0x13
    jc disk_error

    ; --- Cargar mapa (124 sectores restantes) en 0x9000 ---
    mov ax, 0x9000
    mov es, ax          ; ES = 0x9000
    xor bx, bx          ; ES:BX = 0x9000:0000
    mov ah, 0x02
    mov al, 124         ; 124 sectores (62 KB)
    mov cl, 3           ; Siguientes sectores (3-126)
    int 0x13
    jc disk_error

    ; --- Dibujar mapa ---
    call draw_map

    ; --- Saltar a square.asm (0x7E00) ---
    jmp 0x0000:0x7E00

draw_map:
    push ds
    push es
    mov ax, 0xA000
    mov es, ax          ; ES = segmento de video
    mov ax, 0x9000
    mov ds, ax          ; DS = segmento de datos del mapa
    xor si, si
    xor di, di
    mov cx, 32000       ; 320x200 = 64,000 bytes (pero movsw usa words)
    rep movsw           ; Copiar mapa a memoria de video
    pop es
    pop ds
    ret

disk_error:
    mov si, error_msg
    call print_string
    jmp $

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

error_msg db "Error de disco!", 0

times 510-($-$$) db 0
dw 0xAA55              ; Firma del MBR