[org 0x8400]
[bits 16]

start:
    ; --- Leer entrada del teclado ---
    mov ah, 0x01        ; Comprobar si hay una tecla presionada
    int 0x16
    jz .move          ; Si no hay tecla, salir

    mov ah, 0x00        ; Leer la tecla presionada
    int 0x16
    ; jmp .move

    ; --- Manejar teclas de flecha ---
    cmp ah, 0x11        ; W
    je .move_up1

    cmp ah, 0x1F        ; S
    je .move_down1

    cmp ah, 0x1E        ; A
    je .move_left1

    cmp ah, 0x20        ; D
    je .move_right1

    cmp ah, 0x48        ; Flecha arriba
    je .move_up2

    cmp ah, 0x50        ; Flecha abajo
    je .move_down2

    cmp ah, 0x4B        ; Flecha izquierda
    je .move_left2
    
    cmp ah, 0x4D        ; Flecha derecha
    je .move_right2
    ; mov word [player1_dir], 0
    ; mov word [player2_dir], 0
    jmp end_script            ; Ignorar otras teclas


.move_up1:
    mov byte [player1_dir], 2
    call erase1
    sub word [player1_y], 5   ; Mover hacia arriba
    call check_collision1
    jmp redraw1

.move_down1:
    mov byte [player1_dir], 4
    call erase1
    add word [player1_y], 5   ; Mover hacia abajo
    call check_collision1
    jmp redraw1

.move_left1:
    mov byte [player1_dir], 3
    call erase1
    sub word [player1_x], 5   ; Mover hacia la izquierda
    call check_collision1
    jmp redraw1

.move_right1:
    mov byte [player1_dir], 1
    call erase1
    add word [player1_x], 5   ; Mover hacia la derecha
    call check_collision1
    jmp redraw1




.move_up2:
    mov byte [player2_dir], 2
    call erase2
    sub word [player2_y], 5   ; Mover hacia arriba
    call check_collision2
    jmp redraw2

.move_down2:
    mov byte [player2_dir], 4
    call erase2
    add word [player2_y], 5   ; Mover hacia abajo
    call check_collision2
    jmp redraw2

.move_left2:
    mov byte [player2_dir], 3
    call erase2
    sub word [player2_x], 5   ; Mover hacia la izquierda
    call check_collision2
    jmp redraw2

.move_right2:
    mov byte [player2_dir], 1
    call erase2
    add word [player2_x], 5   ; Mover hacia la derecha
    call check_collision2
    jmp redraw2

.move:
    ; Mover jugador en la dirección actual
    cmp byte [player1_dir], 0
    je redraw1
    cmp byte [player1_dir], 1
    je .move_right1
    cmp byte [player1_dir], 2
    je .move_up1
    cmp byte [player1_dir], 3
    je .move_left1
    cmp byte [player1_dir], 4
    je .move_down1
    jmp .no_key

.move2:
    ; Mover jugador en la dirección actual
    cmp byte [player2_dir], 0
    je redraw2
    cmp byte [player2_dir], 1
    je .move_right2
    cmp byte [player2_dir], 2
    je .move_up2
    cmp byte [player2_dir], 3
    je .move_left2
    cmp byte [player2_dir], 4
    je .move_down2
    jmp .no_key

.no_key:
    ; No hacer nada si no hay tecla
    jmp end_script

erase1:
    ; Borrar jugador en la posición anterior
   call load_player1
    jmp erase

erase2:
    ; Borrar jugador en la posición anterior
    call load_player2
erase:
    mov byte [sq_color], 0x00 ; Negro (borrar)
    call draw_square
    ret

redraw1:
    ; Dibujar jugador en la nueva posición
    call load_player1
    call draw_square
    jmp start.move2

redraw2:
    ; Dibujar jugador en la nueva posición
    call load_player2
    call draw_square
    jmp end_script

load_player1:
    mov ax, [player1_x]
    mov word [sq_x], ax
    mov ax, [player1_y]
    mov word [sq_y], ax
    mov byte [sq_color], 0x09
    ret

load_player2:
    mov ax, [player2_x]
    mov word [sq_x], ax
    mov ax, [player2_y]
    mov word [sq_y], ax
    mov byte [sq_color], 0x05 ; Rojo (jugador)
    ret

end_script:
    ret

; --- Variables locales ---
player1_x equ 0xA000 ; Posición X del jugador 1
player1_y equ 0xA010    ; Posición Y del jugador 1
player2_x equ 0xA020     ; Posición X del jugador 2
player2_y equ 0xA030    ; Posición Y del jugador 2
sq_x dw 0          ; Coordenada X del cuadrado
sq_y dw 0          ; Coordenada Y del cuadrado
sq_color db 0      ; Color del cuadrado
sq_width dw 4      ; Ancho del cuadrado
sq_height dw 4     ; Altura del cuadrado
player1_dir db 0    ; Dirección del jugador [0=stop, 1=right, 2=up, 3=left, 4=down]
player2_dir db 0    ; Dirección del jugador [0=stop, 1=right, 2=up, 3=left, 4=down]


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

check_collision1:
    ; Calculate the video memory address for the next position
    mov ax, [player1_y]       ; Get Y position
    imul ax, 320             ; Y * 320 (screen width)
    add ax, [player1_x]       ; Add X position
    mov di, ax               ; Store the offset in DI

    call middle_colision
    jne no_collision         ; If not white, continue

    ; Reset player position to initial values
    mov word [player1_x], 52  ; Initial X position
    mov word [player1_y], 100 ; Initial Y position
    mov byte [player1_dir], 0 ; Stop the player


no_collision:
    ret

check_collision2:
    ; Calculate the video memory address for the next position
    mov ax, [player2_y]       ; Get Y position
    imul ax, 320             ; Y * 320 (screen width)
    add ax, [player2_x]       ; Add X position
    mov di, ax               ; Store the offset in DI

    call middle_colision
    jne no_collision         ; If not white, continue

    ; Reset player position to initial values
    mov word [player2_x], 42  ; Initial X position
    mov word [player2_y], 100 ; Initial Y position
    mov byte [player2_dir], 0 ; Stop the player
    ; jmp redraw              ; Redraw the player at the initial position
    ret

middle_colision:
    ; Set ES to video memory segment
    mov ax, 0xA000
    mov es, ax

    ; Read the pixel color at ES:[DI]
    mov al, byte [es:di]
    cmp al, 0x0F             ; Check if the color is White (0x0F)
    ret

times 510-($-$$) db 0
dw 0xAA55