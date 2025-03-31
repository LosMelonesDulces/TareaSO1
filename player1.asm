[org 0x8400]
[bits 16]

start:
    ; ; --- Leer entrada del teclado ---
    mov ah, 0x01        ; Comprobar si hay una tecla presionada
    int 0x16
    jz .move          ; Si no hay tecla, salir

    mov ah, 0x00        ; Leer la tecla presionada
    int 0x16


    ; --- Manejar teclas de flecha ---
    cmp ah, 0x48        ; Flecha arriba
    mov word [player_dir], 2
    je .move
    cmp ah, 0x50        ; Flecha abajo
    mov word [player_dir], 4
    je .move
    cmp ah, 0x4B        ; Flecha izquierda
    mov word [player_dir], 3
    je .move
    cmp ah, 0x4D        ; Flecha derecha
    mov word [player_dir], 1
    je .move
    mov word [player_dir], 0
    jmp .end            ; Ignorar otras teclas
; start:
;     ; Leer el puerto del teclado
;     in al, 0x60          ; Leer el scan code del puerto 0x60
;     test al, 0x80        ; Comprobar si el bit 7 (MSB) está establecido
;     jz .key_pressed      ; Si el bit 7 no está establecido, es un make code
;     jmp .key_released    ; Si el bit 7 está establecido, es un break code

; .key_pressed:
;     ; Aquí manejas la tecla presionada
;     cmp al, 0x48         ; Flecha arriba (make code)
;     je .move_up
;     cmp al, 0x50         ; Flecha abajo (make code)
;     je .move_down
;     cmp al, 0x4B         ; Flecha izquierda (make code)
;     je .move_left
;     cmp al, 0x4D         ; Flecha derecha (make code)
;     je .move_right
;     jmp .end


; .key_released:
;     ; Aquí manejas la tecla liberada
;     ; cmp al, 0xC8         ; Flecha arriba (break code = 0x48 + 0x80)
;     ; je .release_up
;     ; cmp al, 0xD0         ; Flecha abajo (break code = 0x50 + 0x80)
;     ; je .release_down
;     jmp .end


.move_up:
    call .erase
    sub word [player_y], 5   ; Mover hacia arriba
    jmp .redraw

.move_down:
    call .erase
    add word [player_y], 5   ; Mover hacia abajo
    jmp .redraw

.move_left:
    call .erase
    sub word [player_x], 5   ; Mover hacia la izquierda
    jmp .redraw

.move_right:
    call .erase
    add word [player_x], 5   ; Mover hacia la derecha
    jmp .redraw

.move:
    ; Mover jugador en la dirección actual
    cmp word [player_dir], 0
    je .redraw
    cmp word [player_dir], 1
    je .move_right
    cmp word [player_dir], 2
    je .move_up
    cmp word [player_dir], 3
    je .move_left
    cmp word [player_dir], 4
    je .move_down
    jmp .no_key


.erase:
    ; Borrar jugador en la posición anterior
    mov ax, [player_x]
    mov word [sq_x], ax
    mov ax, [player_y]
    mov word [sq_y], ax
    mov byte [sq_color], 0x00 ; Negro (borrar)
    call draw_square
    ret

.redraw:
    ; Dibujar jugador en la nueva posición
    mov ax, [player_x]
    mov word [sq_x], ax
    mov ax, [player_y]
    mov word [sq_y], ax
    mov byte [sq_color], 0x09 ; Rojo (jugador)
    call draw_square
    jmp .end

.no_key:
    ; No hacer nada si no hay tecla
    jmp .end

.end:
    ret

; --- Variables locales ---
player_x dw 42     ; Posición inicial X del jugador
player_y dw 100    ; Posición inicial Y del jugador
sq_x dw 0          ; Coordenada X del cuadrado
sq_y dw 0          ; Coordenada Y del cuadrado
sq_color db 0      ; Color del cuadrado
sq_width dw 4      ; Ancho del cuadrado
sq_height dw 4     ; Altura del cuadrado
player_dir dw 0    ; Dirección del jugador [0=stop, 1=right, 2=up, 3=left, 4=down]

draw_square:
    ; Dibuja un cuadrado en la posición [sq_x], [sq_y] con el color [sq_color]
    mov word di, [sq_y]      ; Y position
    imul di, 320             ; Y * 320 (filas)
    add di, [sq_x]           ; + X position
    mov al, [sq_color]
    mov cx, [sq_height]      ; Altura del cuadrado

.row_loop:
    push cx
    mov cx, [sq_width]       ; Ancho del cuadrado
    rep stosb                ; Dibujar fila
    add di, 320              ; Siguiente fila
    sub di, [sq_width]
    pop cx
    loop .row_loop
    ret