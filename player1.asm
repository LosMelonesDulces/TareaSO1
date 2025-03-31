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
    jmp end_script            ; Ignorar otras teclas


.move_up:
    call erase
    sub word [player_y], 5   ; Mover hacia arriba
    call check_collision
    jmp redraw

.move_down:
    call erase
    add word [player_y], 5   ; Mover hacia abajo
    call check_collision
    jmp redraw

.move_left:
    call erase
    sub word [player_x], 5   ; Mover hacia la izquierda
    call check_collision
    jmp redraw

.move_right:
    call erase
    add word [player_x], 5   ; Mover hacia la derecha
    call check_collision
    jmp redraw

.move:
    ; Mover jugador en la dirección actual
    cmp word [player_dir], 0
    je redraw
    cmp word [player_dir], 1
    je .move_right
    cmp word [player_dir], 2
    je .move_up
    cmp word [player_dir], 3
    je .move_left
    cmp word [player_dir], 4
    je .move_down
    jmp .no_key

.no_key:
    ; No hacer nada si no hay tecla
    jmp end_script

erase:
    ; Borrar jugador en la posición anterior
    mov ax, [player_x]
    mov word [sq_x], ax
    mov ax, [player_y]
    mov word [sq_y], ax
    mov byte [sq_color], 0x00 ; Negro (borrar)
    call draw_square
    ret

redraw:
    ; Dibujar jugador en la nueva posición
    mov ax, [player_x]
    mov word [sq_x], ax
    mov ax, [player_y]
    mov word [sq_y], ax
    mov byte [sq_color], 0x09 ; Rojo (jugador)
    call draw_square
    jmp end_script


end_script:
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

check_collision:
    ; Calculate the video memory address for the next position
    mov ax, [player_y]       ; Get Y position
    imul ax, 320             ; Y * 320 (screen width)
    add ax, [player_x]       ; Add X position
    mov di, ax               ; Store the offset in DI

    ; Set ES to video memory segment
    mov ax, 0xA000
    mov es, ax

    ; Read the pixel color at ES:[DI]
    mov al, byte [es:di]
    cmp al, 0x0F             ; Check if the color is White (0x0F)
    jne .no_collision         ; If not white, continue

    ; Reset player position to initial values
    mov word [player_x], 42  ; Initial X position
    mov word [player_y], 100 ; Initial Y position
    mov word [player_dir], 0 ; Stop the player
    ; jmp redraw              ; Redraw the player at the initial position

.no_collision:
    ret