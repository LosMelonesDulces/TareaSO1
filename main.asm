org 0x7C00

start:
    ; --- Inicialización ---
    xor ax, ax
    mov ds, ax          ; DS = 0 para acceder a nuestras variables
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; --- Modo Video 13h ---
    mov ax, 0x0013
    int 0x10

    ; --- Cargar mapa (125 sectores) ---
    mov ax, 0x8000
    mov es, ax          ; ES temporalmente a 0x8000 para carga
    xor bx, bx
    mov ah, 0x02
    mov al, 125
    mov ch, 0
    mov dh, 0
    mov cl, 2
    int 0x13
    jc disk_error

    ; --- Dibujar mapa ---
    call draw_map

    ; --- Configurar ES para memoria de video ---
    mov ax, 0xA000
    mov es, ax

    ; --- Dibujar cuadrado ---
    mov word [sq_x], 47
    mov word [sq_y], 100
    mov byte [sq_color], 0x01 ; Azul
    call draw_square

    mov word [sq_x], 55
    mov word [sq_y], 100
    mov byte [sq_color], 0x04  ; rojo
    call draw_square 

    ; --- Bucle infinito ---
    jmp $

draw_map:
    push ds             ; Guardar DS original
    push es
    
    mov ax, 0xA000
    mov es, ax          ; ES = segmento de video
    mov ax, 0x8000
    mov ds, ax          ; DS = segmento de datos cargados
    xor si, si
    xor di, di
    mov cx, 32000
    rep movsw
    
    pop es              ; Restaurar ES
    pop ds              ; Restaurar DS
    ret

draw_square:
    ; Asegurar que DS apunte a nuestro segmento de datos
    push ds
    xor ax, ax
    mov ds, ax
    
    ; Calcular posición en memoria de video
    mov ax, [sq_y]      ; Y (accede via DS)
    mov bx, 320         ; Ancho de pantalla
    mul bx              ; ax = Y * 320
    add ax, [sq_x]      ; ax = Y * 320 + X (accede via DS)
    mov di, ax          ; DI = posición inicial
    
    ; Dibujar el cuadrado
    xor dx, dx          ; Contador de filas

draw_row:
    xor cx, cx          ; Contador de columnas
    
draw_pixel:
    mov al, [sq_color]  ; Cargar color (accede via DS)
    mov byte [es:di], al ; Establecer color
    inc di              ; Siguiente píxel
    inc cx
    cmp cx, [sq_width]  ; ¿Terminamos la fila? (accede via DS)
    jl draw_pixel

    add di, 320         ; Saltar a siguiente línea
    sub di, [sq_width]  ; Ajustar posición (accede via DS)
    inc dx
    cmp dx, [sq_height] ; ¿Terminamos? (accede via DS)
    jl draw_row
    
    pop ds              ; Restaurar DS
    ret

; --- Variables ---
sq_x dw 100             ; Coordenada X
sq_y dw 50              ; Coordenada Y
sq_width dw 4          ; Ancho
sq_height dw 4         ; Alto
sq_color dw 0x01
blue_car_d dd 0

; --- Manejo de errores ---
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

times 510 - ($ - $$) db 0
dw 0xAA55