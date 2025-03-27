org 0x7C00

start:
    call read           ; Llama a la rutina para leer la matriz desde el disco
    call draw_square    ; Llama a la rutina para dibujar el cuadrado

    jmp $               ; Bucle infinito para detener la ejecución

read:
    ; Configurar el modo de video 13h (320x200, 256 colores)
    mov ax, 0x0013       ; Modo de video 13h
    int 0x10             ; Llamar a la BIOS para cambiar el modo de video

    ; Configurar el segmento de video
    mov ax, 0xA000       ; Segmento de memoria de video
    mov es, ax           ; ES apunta a la memoria de video

    ; Configurar los parámetros para leer sectores
    xor bx, bx           ; Offset en la memoria de video (bx = 0)
    mov dl, 0x00         ; Unidad de disco (0x00 = disco virtual en QEMU)
    mov dh, 0            ; Cabeza 0
    mov ch, 0            ; Cilindro 0
    mov cl, 2            ; Sector inicial (sector 2, después del sector de arranque)

    mov si, 126          ; Número de sectores a leer
    mov di, 0            ; Contador de sectores leídos en la cabeza actual

read_sector:
    ;push si              ; Guardar el contador de sectores
    mov ah, 0x02         ; Función 02h: Leer sectores
    mov al, 1            ; Leer 1 sector
    mov bx, bx           ; Offset en la memoria de video
    mov dl, 0x00         ; Unidad de disco
    int 0x13             ; Llamar a la BIOS para leer el sector
    jc error             ; Si hay un error, saltar a "error"

    add bx, 512          ; Avanzar 512 bytes en la memoria de video
    inc cl               ; Avanzar al siguiente sector
    inc di               ; Incrementar el contador de sectores leídos

    ; Comprobar si hemos leído 30 sectores en esta cabeza
    cmp di, 35
    je change_head       ; Si hemos leído 30 sectores, cambiar de cabeza

    ;pop si               ; Restaurar el contador de sectores
    dec si               ; Decrementar el contador
    jnz read_sector      ; Repetir hasta que se lean todos los sectores

read_done:
    ret                  ; Asegurar retorno correcto

change_head:
    inc dh               ; Cambiar de cabeza (0 -> 1, 1 -> 2)

    cmp dh, 2            ; Si pasamos la cabeza 1, es hora de cambiar de cilindro
    jne reset_sector     ; Si no hemos pasado de la cabeza 1, solo reiniciar sector

    ; Cambio de cilindro
    inc ch               ; Cambiar al siguiente cilindro
    xor dh, dh           ; Reiniciar la cabeza a 0

reset_sector:
    xor di, di           ; Resetear el contador de sectores leídos
    mov cl, 2            ; Volver al sector 2 en la nueva cabeza/cilindro
    jmp read_sector      ; Volver a leer desde el sector 2

error:
    mov ax, 0x4C00       ; Función para salir de DOS con código de salida 0
    int 0x21             ; Llamada a la interrupción 21h de DOS (salida)

draw_square:
    ; Asegurar que ES apunte a la memoria de video
    ;xor ax, ax
    mov ax, 0xA000
    mov es, ax

    ; Calcular la posición en la memoria de video
    mov ax, [sq_y]      ; Y
    mov bx, 320         ; Ancho de la pantalla
    mul bx              ; ax = Y * 320
    add ax, [sq_x]      ; ax = Y * 320 + X
    mov di, ax          ; Guardar en DI (posición inicial)

    ; Dibujar el cuadrado
    xor dx, dx          ; Contador de filas
draw_row:
    xor cx, cx          ; Contador de columnas
draw_pixel:
    mov byte [es:di], COLOR_WHITE ; Escribir color
    inc di              ; Siguiente píxel
    inc cx
    cmp cx, [sq_width]  ; ¿Terminamos la fila?
    jl draw_pixel

    add di, 320         ; Saltar a la siguiente línea
    sub di, [sq_width]  ; Asegurar alineación
    inc dx
    cmp dx, [sq_height] ; ¿Terminamos el cuadrado?
    jl draw_row

    ret

; Datos
sq_x dw 100             ; Coordenada X
sq_y dw 50              ; Coordenada Y
sq_width dw 40          ; Ancho
sq_height dw 70         ; Alto
COLOR_WHITE equ 0x0F    ; Blanco (valor 15)

; Rellenar hasta 510 bytes
times 510 - ($ - $$) db 0
dw 0xAA55

