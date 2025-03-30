[org 0x8000]
[bits 16]

start:
    ; --- Configurar segmento de video ---
    mov ax, 0xA000
    mov es, ax

    ; --- Borrar cuadrado anterior (pintar de negro) ---
    mov ax, [x_red]
    mov [sq_x], ax
    mov ax, [y_red]
    mov [sq_y], ax
    mov byte [sq_color], 0x00
    call draw_square

    ; --- Mover según checkpoint actual ---
    cmp byte [current_chekpoint_red], 0
    je .chek_point0
    cmp byte [current_chekpoint_red], 1
    je .chek_point1
    cmp byte [current_chekpoint_red], 2
    je .chek_point2
    cmp byte [current_chekpoint_red], 3
    je .chek_point3
    cmp byte [current_chekpoint_red], 4
    je .chek_point4
    cmp byte [current_chekpoint_red], 5
    je .chek_point5
    cmp byte [current_chekpoint_red], 6
    je .chek_point6
    cmp byte [current_chekpoint_red], 7 
    je .chek_point7
    cmp byte [current_chekpoint_red], 8
    je .chek_point8
    cmp byte [current_chekpoint_red], 9
    je .chek_point9

.chek_point0: ; arriba
    dec word [y_red]
    cmp word [y_red], 65
    jg .draw
    mov byte [current_chekpoint_red], 1
    jmp .draw

.chek_point1: ; derecha
    inc word [x_red]
    cmp word [x_red], 110
    jl .draw
    mov byte [current_chekpoint_red], 2
    jmp .draw

.chek_point2: ; arriba
    dec word [y_red]
    cmp word [y_red], 20
    jg .draw
    mov byte [current_chekpoint_red], 3
    jmp .draw

.chek_point3: ; derecha
    inc word [x_red]
    cmp word [x_red], 190
    jl .draw
    mov byte [current_chekpoint_red], 4
    jmp .draw

.chek_point4: ; abajo
    inc word [y_red]
    cmp word [y_red], 95
    jl .draw
    mov byte [current_chekpoint_red], 5
    jmp .draw

.chek_point5: ; derecha
    inc word [x_red]
    cmp word [x_red], 260
    jl .draw
    mov byte [current_chekpoint_red], 6
    jmp .draw

.chek_point6: ; abajo
    inc word [y_red]
    cmp word [y_red], 130
    jl .draw
    mov byte [current_chekpoint_red], 7
    jmp .draw

.chek_point7: ; izquierda    
    dec word [x_red]
    cmp word [x_red], 160
    jg .draw
    mov byte [current_chekpoint_red], 8
    jmp .draw

.chek_point8: ; abajo    
    inc word [y_red]
    cmp word [y_red], 165
    jl .draw
    mov byte [current_chekpoint_red], 9
    jmp .draw

.chek_point9: ; izquierda
    dec word [x_red]
    cmp word [x_red], 52
    jg .draw
    inc byte [laps]
    mov byte [current_chekpoint_red], 0
    jmp .draw

.draw:
    ; --- Dibujar cuadrado en nueva posición ---
    mov ax, [x_red]
    mov [sq_x], ax
    mov ax, [y_red]
    mov [sq_y], ax
    mov byte [sq_color], 0x04 ; Color rojo
    call draw_square

    ; --- Cambiar turno ---
    mov byte [0x7DFE], 1

.skip_turn:
    retf

draw_square:
    mov di, [sq_y]      ; Y position
    imul di, 320        ; Y * 320 (filas)
    add di, [sq_x]      ; + X position
    mov al, [sq_color]
    mov cx, [sq_height] ; Altura del cuadrado

.row_loop:
    push cx
    mov cx, [sq_width]  ; Ancho del cuadrado
    rep stosb           ; Dibujar fila
    add di, 320         ; Siguiente fila
    sub di, [sq_width]
    pop cx
    loop .row_loop
    ret

; --- Variables locales ---
sq_x dw 0
sq_y dw 0
sq_width dw 4
sq_height dw 4
sq_color db 0
laps db 0

x_red dw 52    ; Posición inicial X (diferente a blue para no solaparse)
y_red dw 100   ; Posición inicial Y
current_chekpoint_red db 0  ; checkpoint inicial

times 512-($-$$) db 0