#!/bin/bash

# Generar los binarios
python3 matriz.py
nasm -f bin main.asm -o main.bin

# Variables
DISK_IMAGE="disco.img"
BOOTLOADER_BIN="main.bin"
MATRIZ_BIN="track_matrix.bin"


qemu-img create -f raw -o $DISK_IMAGE

# Escribir los binarios en sus sectores respectivos
dd if=$BOOTLOADER_BIN of=$DISK_IMAGE bs=512 count=1 conv=notrunc     # Sector 0 (bootloader)
dd if=$MATRIZ_BIN of=$DISK_IMAGE bs=512 seek=1 conv=notrunc          # Desde el sector 1 al 125

# Iniciar QEMU con la imagen del disco creada
qemu-system-i386 -fda $DISK_IMAGE