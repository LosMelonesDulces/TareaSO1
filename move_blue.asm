[org 0x7E00]
[bits 16]

start:
    ; --- Configurar segmento de video ---
    mov ax, 0xA000
    mov es, ax

    ; --- Borrar cuadrado anterior (pintar de negro) ---
    mov ax, [x_blue]
    mov [sq_x], ax
    mov ax, [y_blue]
    mov [sq_y], ax
    mov byte [sq_color], 0x00
    call draw_square

    mov al, [0x7DFA]
    mov cl, al
    xor ch, ch

    ; --- Mover según checkpoint actual ---
    cmp byte [current_chekpoint_blue], 0
    je .chek_point0
    cmp byte [current_chekpoint_blue], 1
    je .chek_point1
    cmp byte [current_chekpoint_blue], 2
    je .chek_point2
    cmp byte [current_chekpoint_blue], 3
    je .chek_point3
    cmp byte [current_chekpoint_blue], 4
    je .chek_point4
    cmp byte [current_chekpoint_blue], 5
    je .chek_point5
    cmp byte [current_chekpoint_blue], 6
    je .chek_point6
    cmp byte [current_chekpoint_blue], 7 
    je .chek_point7
    cmp byte [current_chekpoint_blue], 8
    je .chek_point8
    cmp byte [current_chekpoint_blue], 9
    je .chek_point9

.chek_point0: ; arriba
    sub word [y_blue], cx
    cmp word [y_blue], 60
    jg .draw
    mov byte [current_chekpoint_blue], 1
    add word [lap_count], 1
    jmp .draw

.chek_point1: ; derecha
    add word [x_blue], cx
    cmp word [x_blue], 125
    jl .draw
    mov byte [current_chekpoint_blue], 2
    jmp .draw

.chek_point2: ; arriba
    sub word [y_blue], cx
    cmp word [y_blue], 30
    jg .draw
    mov byte [current_chekpoint_blue], 3
    jmp .draw

.chek_point3: ; derecha
    add word [x_blue], cx
    cmp word [x_blue], 200
    jl .draw
    mov byte [current_chekpoint_blue], 4
    jmp .draw

.chek_point4: ; abajo
    add word [y_blue], cx
    cmp word [y_blue], 100
    jl .draw
    mov byte [current_chekpoint_blue], 5
    jmp .draw

.chek_point5: ; derecha
    add word [x_blue], cx
    cmp word [x_blue], 270
    jl .draw
    mov byte [current_chekpoint_blue], 6
    jmp .draw

.chek_point6: ; abajo
    add word [y_blue], cx    
    cmp word [y_blue], 125
    jl .draw
    mov byte [current_chekpoint_blue], 7
    jmp .draw

.chek_point7: ; izquierda    
    sub word [x_blue], cx    
    cmp word [x_blue], 145
    jg .draw
    mov byte [current_chekpoint_blue], 8
    jmp .draw

.chek_point8: ; abajo    
    add word [y_blue], cx
    cmp word [y_blue], 170
    jl .draw
    mov byte [current_chekpoint_blue], 9
    jmp .draw

.chek_point9: ; izquierda
    sub word [x_blue], cx
    cmp word [x_blue], 42
    jg .draw
    inc byte [laps]
    mov byte [current_chekpoint_blue], 0
    jmp .draw

.draw:
    ; --- Dibujar cuadrado en nueva posición ---
    mov word ax, [x_blue]
    mov word [sq_x], ax
    mov word ax, [y_blue]
    mov word [sq_y], ax
    mov byte [sq_color], 0x01 ; Color azul
    call draw_square
    ret

draw_square:
    mov word di, [sq_y]      ; Y position
    imul di, 320        ; Y * 320 (filas)
    add word di, [sq_x]      ; + X position
    mov byte al, [sq_color]
    mov word cx, [sq_height] ; Altura del cuadrado

.row_loop:
    push cx
    mov word cx, [sq_width]  ; Ancho del cuadrado
    rep stosb           ; Dibujar fila
    add word di, 320         ; Siguiente fila
    sub word di, [sq_width]
    pop cx
    loop .row_loop
    ret

; --- Variables locales ---
sq_x dw 0
sq_y dw 0
sq_width dw 4
sq_height dw 4
sq_color db 0

x_blue dw 42    ; Posición inicial X
y_blue dw 100   ; Posición inicial Y
current_chekpoint_blue db 0  ; checkpoint inicial
laps db 0

lap_count equ 0xA040

times 512-($-$$) db 0