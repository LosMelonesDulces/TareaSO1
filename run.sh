#!/bin/bash

# Generar los binarios
python3 matriz.py
nasm -f bin main.asm -o main.bin
nasm -f bin square.asm -o square.bin

# Variables
DISK_IMAGE="disco.img"
BOOTLOADER_BIN="main.bin"
SQUARE_BIN="square.bin"
MATRIZ_BIN="track_matrix_large_track.mat"
SIZE_IN_MB=2  # Tamaño del disco en MB

# Crear imagen de disco
qemu-img create -f raw $DISK_IMAGE ${SIZE_IN_MB}M

# Escribir los binarios en sus sectores respectivos
dd if=$BOOTLOADER_BIN of=$DISK_IMAGE bs=512 count=1 conv=notrunc     # Sector 0 (bootloader)
dd if=$SQUARE_BIN of=$DISK_IMAGE bs=512 seek=1 conv=notrunc          # Sector 1 (square.bin)
dd if=$MATRIZ_BIN of=$DISK_IMAGE bs=512 seek=2 conv=notrunc          # Desde sector 2 en adelante

# Iniciar QEMU con la imagen del disco creada
qemu-system-i386 -drive format=raw,file=$DISK_IMAGE