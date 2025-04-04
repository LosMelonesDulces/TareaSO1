[org 0x7C00]
[bits 16]

    ; --- Inicialización ---
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; --- Modo Video 13h ---
    mov ax, 0x0013
    int 0x10

    ; --- Cargar módulos ---
    ; Cargar move_blue en 0x7E00
    mov ax, 0x0000
    mov es, ax
    mov bx, 0x7E00
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov dh, 0
    mov cl, 2
    int 0x13
    jc disk_error

    ; Cargar move_red en 0x8000
    mov bx, 0x8000
    mov ah, 0x02
    mov al, 1
    mov cl, 3
    int 0x13
    jc disk_error

    ; Cargar move_green en 0x8200
    mov bx, 0x8200      ; Nueva posición para move_green
    mov ah, 0x02
    mov al, 1           ; 1 sector
    mov cl, 4           ; Sector (2=blue, 3=red, 4=green)
    int 0x13
    jc disk_error

    ; Cargar player en 0x8400
    mov bx, 0x8400
    mov ah, 0x02
    mov al, 1
    mov cl, 5
    int 0x13
    jc disk_error

    ; Cargar lap_controller en 0x8600
    mov bx, 0x8600
    mov ah, 0x02
    mov al, 1
    mov cl, 6
    int 0x13
    jc disk_error

    ; Cargar mapa en 0x9000
    mov ax, 0x9000
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 125
    mov cl, 7
    int 0x13
    jc disk_error

    ; Posiciones iniciales
    mov word [0xA000], 90
    mov word [0xA010], 150
    mov word [0xA020], 34
    mov word [0xA030], 100

    ; --- Dibujar mapa inicial ---
    call draw_map

    ; --- Inicializar variable de turno ---
    mov byte [turn], 0

assign_speed:
    ; velocidad azul
    call get_random
    mov [0x7DFA], al
    ; velocidad rojo
    call get_random
    mov [0x7DFB], al
    ; velocidad verde
    call get_random
    mov [0x7DFC], al

; --- Bucle principal SIN temporizador ---
main_loop:

; .player2:
    call 0x0000:0x8400
; .blue:
    call 0x0000:0x7E00
; .red:
    call 0x0000:0x8000
; .green:
    call 0x0000:0x8200
; .lap_controller:
    call 0x0000:0x8600

; .delay:
    ; Delay usando BIOS (funciona bien en QEMU)
    mov ah, 0x86
    mov cx, 0x0000 ; Parte alta del delay (microsegundos)
    mov dx, 0xC350          ; Parte baja (0x0000 = ~65536 µs)
    ;mov dx, 0x2710         ; Parte baja (0x0000 = ~65536 µs)
    int 0x15
    sub word [end_timer], 0x0001
    cmp word [end_timer], 0
    jl end_script
    
    jmp main_loop

; --- Funciones ---
draw_map:
    push ds
    push es
    mov ax, 0xA000
    mov es, ax
    mov ax, 0x9000
    mov ds, ax
    xor si, si
    xor di, di
    mov cx, 32000
    rep movsw
    pop es
    pop ds
    ret

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

generate_random:
    ; Usar el contador de ticks como semilla
    mov ah, 0x00
    int 0x1A        ; DX = ticks desde medianoche
    
    ; Algoritmo simple para mejorar aleatoriedad
    mov ax, dx
    mov bx, 0x8405
    mul bx          ; AX = AX * BX
    add ax, 0x1234  ; Sumar constante
    xor ax, [n_tropy]
    inc byte [n_tropy]
    xor dx, dx
    ret

get_random:
    call generate_random
    mov bx, 5
    div bx
    mov al, dl
    inc al
    ret

end_script:
    ; --- Fin del programa ---
    


    call draw_screen
    mov eax, 1        ; Número de syscall para exit
    mov ebx, 0        ; Código de salida (0 = éxito)
    int 0x80          ; Llamada al kernel    mov ebx, 0        ; Código de salida (0 = éxito)
    int 0x80          ; Llamada al kernel

draw_screen:
    mov di, 0
    mov al, [sq_color]

.row_loop:
    push cx
    mov cx, 64000  ; Ancho del cuadrado
    rep stosb
    pop cx
    loop .row_loop
    ret

n_tropy db 0

; --- Datos ---
error_msg db "Error de disco!", 0
turn db 0  ; Variable de turno (0=azul, 1=rojo)
delay_amount dw 0x0000
end_timer dw 0x04B0

blue_laps equ 0xA040    ; Laps del bot azul
green_laps equ 0xA050  ; Laps del bot verde
red_laps equ 0xA060    ; Laps del bot rojo
player1_laps equ 0xA070 ; Laps del jugador 1
player2_laps equ 0xA080 ; Laps del jugador 2
sq_color equ 0xA090


; --- Relleno y firma ---
times 510-($-$$) db 0
dw 0xAA55
