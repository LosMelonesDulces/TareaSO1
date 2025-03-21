[org 0x7E00]  ; Cargado aquí por el bootloader

start:
    mov si, mapa         ; índice de la matriz
    mov di, 0xA000       ; segmento de video
    mov es, di
    xor di, di           ; offset en video (es:di = 0xA000:0000)
    
    ; coordenadas
    xor cx, cx           ; fila (y)
next_row:
    xor dx, dx           ; columna (x)
next_col:
    mov al, [si]         ; obtener valor del mapa
    cmp al, 1
    je pared
    mov al, 0x00         ; color negro
    jmp pintar
pared:
    mov al, 0x0F         ; color blanco
pintar:
    ; calcular posicion en video: (y * 320) + x
    mov bx, cx
    mov ax, bx
    mov bx, 320
    mul bx               ; ax = y * 320
    add ax, dx           ; ax += x
    mov di, ax
    mov [es:di], al      ; pintar pixel
    
    inc si               ; siguiente valor de la matriz
    inc dx
    cmp dx, 20
    jl next_col

    inc cx
    cmp cx, 10
    jl next_row

    jmp $

; mapa 20x10: 0 = vacío, 1 = pared
; formato plano: fila por fila
mapa:
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,0,1
    db 1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,1
    db 1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,1
    db 1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

times 512 - ($ - $$) db 0   ; Rellenar sector
