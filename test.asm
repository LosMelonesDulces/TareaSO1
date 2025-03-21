ORG 0x7E00  ; Dirección de carga del bootloader (el BIOS carga el bootloader en esta dirección)

; Código principal
start:
   call draw_square ; Llama a la subrutina para dibujar un cuadrado en pantalla

   jmp $              ; Bucle infinito (detiene la ejecución del programa)




; Subrutina para dibujar un cuadrado
draw_square:
   mov edi, DRAW_START ; Configura EDI con la dirección base de la memoria de video (0xA0000)
   mov eax, [sq_y]         ; Configura EAX con la posición inicial en Y (50)  
   mov ebx, 320        ; Configura EBX con el ancho de la pantalla (320 píxeles por fila)
   mul ebx             ; Calcula la posición en memoria: Y * 320
   add eax, edi        ; Suma la dirección base de la memoria de video
   mov edi, eax        ; Actualiza EDI con la posición calculada
   add edi, [sq_x]

   jmp put_pixel       ; Salta a la subrutina para dibujar un píxel

; Subrutina para mover hacia abajo (no implementada)
move_down:
   add edi, 320
   sub edi, [sq_width]
   xor ecx, ecx

; Subrutina para dibujar un píxel
put_pixel:
   mov byte [edi], COLOR_WHITE ; Escribe el color rojo (0x04) en la posición de memoria apuntada por EDI
   inc edi 
   inc ecx 
   cmp ecx, [sq_width]
   jl put_pixel

   inc edx
   cmp edx, [sq_height]
   jl move_down

done:
   ret                 ; Retorna de la subrutina (aunque no se usa en este caso)

; Datos
sq_x dd 100            ; Coordenada X del cuadrado (no se usa en el código actual)
sq_y dd 50             ; Coordenada Y del cuadrado (no se usa en el código actual)
sq_width dd 40         ; Ancho del cuadrado (no se usa en el código actual)
sq_height dd 70        ; Altura del cuadrado (no se usa en el código actual)
DRAW_START equ 0xA0000 ; Dirección de inicio de la memoria de video (modo 0x13 usa esta dirección)
COLOR_RED equ 0x04     ; Color rojo (valor 4 en la paleta de colores de modo 0x13)
COLOR_BLUE equ 0x01
COLOR_GREEN equ 0x02
COLOR_WHITE equ 0xF
