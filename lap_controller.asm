[org 0x8600]
[bits 16]

start:

.p1_checkpoint1:
    cmp byte [checkpoint_1], TRUE
    je .p1_checkpoint2
    cmp word [player1_y], 150
    jl .p2_checkpoint1
    cmp word [player1_x], 90
    jg .p2_checkpoint1
    call toggle_bool1
    jmp .p2_checkpoint1

.p1_checkpoint2:
    cmp word [player1_x], 70
    jg .p2_checkpoint1
    cmp word [player1_y], 100
    jg .p2_checkpoint1
    call toggle_bool1
    add word [player1_laps], 1

.p2_checkpoint1:
    cmp byte [checkpoint_2], TRUE
    je .p2_checkpoint2
    cmp word [player2_y], 150
    jl end_script
    cmp word [player2_x], 90
    jg end_script
    call toggle_bool2
    jmp end_script

.p2_checkpoint2:
    cmp word [player2_x], 70
    jg end_script
    cmp word [player2_y], 100
    jg end_script
    call toggle_bool2
    add word [player2_laps], 1


end_script:
    mov word ax, [blue_laps]
    mov byte [sq_color], 0x01
    cmp word ax, [red_laps]
    jg .skip1
    mov word ax, [red_laps]
    mov byte [sq_color], 0x04
.skip1:
    cmp word ax, [green_laps]
    jg .skip2
    mov word ax, [green_laps]
    mov byte [sq_color], 0x02
.skip2:
    cmp word ax, [player1_laps]
    jg .skip3
    mov word ax, [player1_laps]
    mov byte [sq_color], 0x09
.skip3:
    cmp word ax, [player2_laps]
    jg .skip4
    mov word ax, [player2_laps]
    mov byte [sq_color], 0x05
.skip4:

ret

toggle_bool1:
    cmp byte [checkpoint_1], FALSE
    je .set_true
    mov byte [checkpoint_1], FALSE
    ret

.set_true:
    mov byte [checkpoint_1], TRUE
    ret

toggle_bool2:
    cmp byte [checkpoint_2], FALSE
    je .set_true
    mov byte [checkpoint_2], FALSE
    ret

.set_true:
    mov byte [checkpoint_2], TRUE
    ret

; --- Variables globales ---

player1_x equ 0xA000    ; Posición X del jugador 1
player1_y equ 0xA010    ; Posición Y del jugador 1
player2_x equ 0xA020    ; Posición X del jugador 2
player2_y equ 0xA030    ; Posición Y del jugador 2

checkpoint_1 db 0
checkpoint_2 db 0

blue_laps equ 0xA040    ; Laps del bot azul
green_laps equ 0xA050  ; Laps del bot verde
red_laps equ 0xA060    ; Laps del bot rojo
player1_laps equ 0xA070 ; Laps del jugador 1
player2_laps equ 0xA080 ; Laps del jugador 2

sq_color equ 0xA090

TRUE equ 200
FALSE equ 0

; --- Relleno y firma ---
times 510-($-$$) db 0
dw 0xAA55
   