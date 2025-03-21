ORG 0x7C00

start:
   xor ax, ax
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov sp, 0x7C00

   mov al, 0x13
   int 0x10 

   jmp $


sq_x dd 100
sq_y dd 50
sq_width dd 40
sq_height dd 70
DRAW_START equ 0xA0000
COLOR_RED equ 0x04