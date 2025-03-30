[org 0x8200]
[bits 16]

start:
    ; Verificar turno
    mov al, [0x7DFE]
    cmp al, 2
    ;je .skip_turn

    ; --- Configurar segmento de video ---
    mov ax, 0xA000
    mov es, ax

    ; --- Borrar cuadrado anterior (pintar de negro) ---
    mov ax, [x_green]
    mov [sq_x], ax
    mov ax, [y_green]
    mov [sq_y], ax
    mov byte [sq_color], 0x00
    call draw_square

    ; --- Mover según checkpoint actual ---
    cmp byte [current_chekpoint_green], 0
    je .chek_point0
    cmp byte [current_chekpoint_green], 1
    je .chek_point1
    cmp byte [current_chekpoint_green], 2
    je .chek_point2
    cmp byte [current_chekpoint_green], 3
    je .chek_point3
    cmp byte [current_chekpoint_green], 4
    je .chek_point4
    cmp byte [current_chekpoint_green], 5
    je .chek_point5
    cmp byte [current_chekpoint_green], 6
    je .chek_point6
    cmp byte [current_chekpoint_green], 7 
    je .chek_point7
    cmp byte [current_chekpoint_green], 8
    je .chek_point8
    cmp byte [current_chekpoint_green], 9
    je .chek_point9

.chek_point0: ; arriba
    dec word [y_green]
    cmp word [y_green], 55
    jg .draw
    mov byte [current_chekpoint_green], 1
    jmp .draw

.chek_point1: ; derecha
    inc word [x_green]
    cmp word [x_green], 130
    jl .draw
    mov byte [current_chekpoint_green], 2
    jmp .draw

.chek_point2: ; arriba
    dec word [y_green]
    cmp word [y_green], 25
    jg .draw
    mov byte [current_chekpoint_green], 3
    jmp .draw

.chek_point3: ; derecha
    inc word [x_green]
    cmp word [x_green], 195
    jl .draw
    mov byte [current_chekpoint_green], 4
    jmp .draw

.chek_point4: ; abajo
    inc word [y_green]
    cmp word [y_green], 90
    jl .draw
    mov byte [current_chekpoint_green], 5
    jmp .draw

.chek_point5: ; derecha
    inc word [x_green]
    cmp word [x_green], 280
    jl .draw
    mov byte [current_chekpoint_green], 6
    jmp .draw

.chek_point6: ; abajo
    inc word [y_green]
    cmp word [y_green], 125
    jl .draw
    mov byte [current_chekpoint_green], 7
    jmp .draw

.chek_point7: ; izquierda    
    dec word [x_green]
    cmp word [x_green], 150
    jg .draw
    mov byte [current_chekpoint_green], 8
    jmp .draw

.chek_point8: ; abajo    
    inc word [y_green]
    cmp word [y_green], 160
    jl .draw
    mov byte [current_chekpoint_green], 9
    jmp .draw

.chek_point9: ; izquierda
    dec word [x_green]
    cmp word [x_green], 62
    jg .draw
    inc byte [laps]
    mov byte [current_chekpoint_green], 0
    jmp .draw

.draw:
    ; --- Dibujar cuadrado en nueva posición ---
    mov ax, [x_green]
    mov [sq_x], ax
    mov ax, [y_green]
    mov [sq_y], ax
    mov byte [sq_color], 0x02 ; Color verde
    call draw_square

    ; --- Cambiar turno ---
    mov byte [0x7DFE], 2

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

x_green dw 62    ; Posición inicial X (diferente a blue y red para no solaparse)
y_green dw 100   ; Posición inicial Y
current_chekpoint_green db 0  ; checkpoint inicial
laps db 0

times 512-($-$$) db 0