[org 0x7E00]
[bits 16]

    ; --- Configurar ES para memoria de video ---
    mov ax, 0xA000
    mov es, ax

    ; --- Dibujar cuadrados ---
    mov ax, [x_blue]
    mov word [sq_x], ax
    mov ax, [y_blue]
    mov word [sq_y], ax
    mov byte [sq_color], 0x01 ; Azul
    call draw_square

    mov word [sq_x], 52
    mov word [sq_y], 100
    mov byte [sq_color], 0x04 ; Rojo
    call draw_square

    mov word [sq_x], 62
    mov word [sq_y], 100
    mov byte [sq_color], 0x02 ; verde
    call draw_square

    call Timer_Setup
    ; --- Bucle infinito ---
    jmp $

Timer_Event:
    ; Borrar cuadrado en posición actual
    mov ax, [x_blue]
    mov word [sq_x], ax
    mov ax, [y_blue]
    mov word [sq_y], ax
    mov byte [sq_color], 0x00 ; Negro
    call draw_square
    
    ; Mover según dirección actual
    cmp byte [current_chekpoint], 0
    je .chek_point0
    cmp byte [current_chekpoint], 1
    je .chek_point1
    cmp byte [current_chekpoint], 2
    je .chek_point2
    cmp byte [current_chekpoint], 3
    je .chek_point3
    cmp byte [current_chekpoint], 4
    je .chek_point4
    cmp byte [current_chekpoint], 5
    je .chek_point5
    cmp byte [current_chekpoint], 6
    je .chek_point6
    cmp byte [current_chekpoint], 7 
    je .chek_point7
    cmp byte [current_chekpoint], 8
    je .chek_point8
    cmp byte [current_chekpoint], 9
    je .chek_point9


.chek_point0: ;arriba
    dec word [y_blue]
    cmp word [y_blue], 60  ; Punto para cambiar dirección
    jg .draw
    mov byte [current_chekpoint], 1 ; Cambiar a abajo
    jmp .draw

.chek_point1: ;derecha
    inc word [x_blue]
    cmp word [x_blue], 125  ; Punto para cambiar dirección
    jl .draw
    mov byte [current_chekpoint], 2 ; Cambiar a arriba
    jmp .draw

.chek_point2: ;arriba
    dec word [y_blue]
    cmp word [y_blue], 30  ; Punto para cambiar dirección
    jg .draw
    mov byte [current_chekpoint], 3 ; Cambiar a izquierda
    jmp .draw

.chek_point3: ;derecha
    inc word [x_blue]
    cmp word [x_blue], 200  ; Punto para cambiar dirección
    jl .draw
    mov byte [current_chekpoint], 4 ; Cambiar a arriba
    jmp .draw

.chek_point4: ;abajo
    inc word [y_blue]
    cmp word [y_blue], 100  ; Punto para cambiar dirección
    jl .draw
    mov byte [current_chekpoint], 5 ; Cambiar a arriba
    jmp .draw

.chek_point5: ;derecha
    inc word [x_blue]
    cmp word [x_blue], 270  ; Punto para cambiar dirección
    jl .draw
    mov byte [current_chekpoint], 6 ; Cambiar a arriba
    jmp .draw

.chek_point6: ;abajo
    inc word [y_blue]
    cmp word [y_blue], 125  ; Punto para cambiar dirección
    jl .draw
    mov byte [current_chekpoint], 7 ; Cambiar a arriba
    jmp .draw

.chek_point7: ;izquierda    
    dec word [x_blue]
    cmp word [x_blue], 140  ; Punto para cambiar dirección
    jg .draw
    mov byte [current_chekpoint], 8 ; Cambiar a arriba
    jmp .draw

.chek_point8: ;abajo    
    inc word [y_blue]
    cmp word [y_blue], 170  ; Punto para cambiar dirección
    jl .draw
    mov byte [current_chekpoint], 9 ; Cambiar a arriba
    jmp .draw

.chek_point9: ;izquierda
    dec word [x_blue]
    cmp word [x_blue], 42  ; Punto para cambiar dirección
    jg .draw
    mov byte [current_chekpoint], 0 ; Cambiar a arriba
    jmp .draw
    
    
.draw:
    ; Dibujar cuadrado en nueva posición
    mov ax, [x_blue]
    mov word [sq_x], ax
    mov ax, [y_blue]
    mov word [sq_y], ax
    mov byte [sq_color], 0x01 ; Azul
    call draw_square
    ret

timer_interrupt:
   call Timer_Event
   mov al, 0x20
   out 0x20, al
   iret

Timer_Setup:
   cli 
   mov al, 00110100b    ; Channel 0, lobyte/hibyte, rate generator
   out PIT_COMMAND, al
   ; Set the divisor
   mov ax, DIVISOR
   out PIT_CHANNEL_0, al    ; Low byte
   mov al, ah
   out PIT_CHANNEL_0, al    ; High byte
   ; Set up the timer ISR
   mov word [0x0020], timer_interrupt
   mov word [0x0022], 0x0000    ; Enable interrupts
   sti 
   ret

draw_square:
    mov di, [sq_y]      ; Y
    imul di, 320        ; Y * 320 (filas)
    add di, [sq_x]      ; + X
    mov al, [sq_color]
    mov cx, [sq_height] ; Altura del cuadrado

.row_loop:
    push cx
    mov cx, [sq_width]  ; Ancho del cuadrado
    rep stosb           ; Dibujar fila (STOSB: [ES:DI] = AL, DI++)
    add di, 320         ; Siguiente fila (320 - 10)
    sub di, [sq_width]
    pop cx
    loop .row_loop
    ret

; Constantes de dirección
DIR_RIGHT equ 0
DIR_LEFT  equ 1
DIR_UP    equ 2
DIR_DOWN  equ 3

; Variables
sq_x dw 0
sq_y dw 0
sq_width dw 4
sq_height dw 4
sq_color db 0

x_blue dw 50    ; Posición inicial X
y_blue dw 100   ; Posición inicial Y
current_chekpoint_blue db 0  ; checkpoint inicial

PIT_COMMAND equ 0x43
PIT_CHANNEL_0 equ 0x40
PIT_FREQUENCY equ 1193180
DESIRED_FREQ equ 60
DIVISOR equ PIT_FREQUENCY/DESIRED_FREQ

; Rellenar hasta 512 bytes (1 sector)
times 512-($-$$) db 0