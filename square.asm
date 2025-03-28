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
    ; Aquí se puede agregar el código para manejar el evento del temporizador
    ; Por ejemplo, cambiar el color de los cuadrados o moverlos
    ; En este caso, simplemente se redibuja el cuadrado en la misma posición

    mov ax, [x_blue]
    mov word [sq_x], ax
    mov ax, [y_blue]
    mov word [sq_y], ax
    mov byte [sq_color], 0x00 ; Negro
    call draw_square
    
    
    add word [x_blue], 1
    add word [y_blue], 1
    mov ax, [x_blue]
    mov word [sq_x], ax
    mov ax, [y_blue]
    mov word [sq_y], ax
    mov byte [sq_color], 0x01 ; Rojo
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
    mov cx, [sq_height]         ; Altura del cuadrado

.row_loop:
    push cx
    mov cx, [sq_width]          ; Ancho del cuadrado
    rep stosb           ; Dibujar fila (STOSB: [ES:DI] = AL, DI++)
    add di, 320         ; Siguiente fila (320 - 10)
    sub di, [sq_width]
    pop cx
    loop .row_loop
    ret

; Variables
sq_x dw 0
sq_y dw 0
sq_width dw 4
sq_height dw 4
sq_color db 0

x_blue db 42
x_red db 0
x_green db 0

y_blue db 100
y_red db 0
y_green db 0

PIT_COMMAND equ 0x43
PIT_CHANNEL_0 equ 0x40
PIT_FREQUENCY equ 1193180
DESIRED_FREQ equ 60
DIVISOR equ PIT_FREQUENCY/DESIRED_FREQ

; Rellenar hasta 512 bytes (1 sector)
times 512-($-$$) db 0