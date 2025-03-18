SECTION .bss
    fb_descriptor resd 1  ; Descriptor de archivo

SECTION .data
    pixel_data db 0xFF, 0x00, 0x00, 0x00  ; Rojo en formato BGRA (Azul, Verde, Rojo, Alpha)
    square_size equ 50   ; Tamaño del cuadrado (50x50 píxeles)

SECTION .text
global _start
_start:
    ; Abrir /dev/fb0 (sys_open)
    mov eax, 5        ; syscall: open
    mov ebx, framebuffer
    mov ecx, 2        ; O_RDWR (lectura/escritura)
    int 0x80
    cmp eax, 0
    js error_exit      ; Si open falla, salir con error
    mov [fb_descriptor], eax  ; Guardar el descriptor

    ; Bucle para dibujar el cuadrado
    mov ecx, 0        ; Inicializar contador de fila (Y)
draw_square:
    mov edx, 0        ; Inicializar contador de columna (X)
draw_row:
    ; Calcular la posición en memoria (Y * ancho de la pantalla + X)
    mov eax, ecx      ; Y
    mov ebx, 320      ; Ancho de la pantalla (320 píxeles)
    imul eax, ebx     ; Y * 320
    add eax, edx      ; Y * 320 + X
    shl eax, 2        ; Multiplicar por 4 (por el tamaño de un píxel BGRA)
    
    ; Posicionar el cursor en la memoria del framebuffer (sys_lseek)
    mov ebx, [fb_descriptor]
    mov ecx, eax      ; Posición calculada
    mov edx, 0
    mov esi, 0        ; SEEK_SET
    mov eax, 19       ; syscall: lseek
    int 0x80
    cmp eax, 0
    js error_exit      ; Si lseek falla, salir con error

    ; Escribir el píxel (sys_write)
    mov eax, 4        ; syscall: write
    mov ebx, [fb_descriptor]
    mov ecx, pixel_data
    mov edx, 4        ; 4 bytes (BGRA)
    int 0x80
    cmp eax, 0
    js error_exit      ; Si write falla, salir con error

    ; Incrementar X (columna)
    inc edx
    cmp edx, square_size  ; ¿Hemos dibujado 50 píxeles en esta fila?
    jl draw_row        ; Si no, continuar dibujando la fila

    ; Incrementar Y (fila)
    inc ecx
    cmp ecx, square_size  ; ¿Hemos dibujado 50 filas?
    jl draw_square      ; Si no, continuar con la siguiente fila

    ; Salir del programa
    mov eax, 1        ; syscall: exit
    xor ebx, ebx
    int 0x80

error_exit:
    mov eax, 1        ; syscall: exit
    mov ebx, 1        ; Código de error
    int 0x80

SECTION .data
framebuffer db "/dev/fb0", 0
