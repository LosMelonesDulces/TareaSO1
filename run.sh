#!/bin/bash

# Generar binarios
#nasm -f bin bootloader.asm -o boot.bin
nasm -f bin main.asm -o main.bin
nasm -f bin move_blue.asm -o blue.bin
nasm -f bin move_green.asm -o green.bin
nasm -f bin move_red.asm -o red.bin
nasm -f bin player1.asm -o player1.bin
nasm -f bin player2.asm -o player2.bin


# Crear imagen de disco (2MB)
qemu-img create -f raw disco.img 2M

# Escribir en sectores (bootloader va en sector 0)
#dd if=boot.bin of=disco.img bs=512 count=1 conv=notrunc
dd if=main.bin of=disco.img bs=512 count=1 conv=notrunc    # Sector 1
dd if=blue.bin of=disco.img bs=512 seek=1 conv=notrunc    # Sector 2 
dd if=red.bin of=disco.img bs=512 seek=2 conv=notrunc     # Sector 3
dd if=green.bin of=disco.img bs=512 seek=3 conv=notrunc   # Sector 4
dd if=player1.bin of=disco.img bs=512 seek=4 conv=notrunc # Sector 5
dd if=player2.bin of=disco.img bs=512 seek=5 conv=notrunc # Sector 5


# Si tienes matriz de pista:
dd if=track_matrix_large_track.mat of=disco.img bs=512 seek=6 conv=notrunc

# Ejecutar
qemu-system-i386 -drive format=raw,file=disco.img