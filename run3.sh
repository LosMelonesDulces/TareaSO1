#!/bin/bash

# Generar los binarios
python3 matriz.py
nasm -f bin leer.asm -o leer.bin
nasm -f bin test.asm -o test.bin

# Variables
DISK_IMAGE="disk.img"
BOOTLOADER_BIN="leer.bin"
TEST_BIN="test.bin"
MATRIZ_BIN="matriz.bin"
GEO_HEADS=2        # Número de cabezas
GEO_SECTORS=255    # Sectores por pista
GEO_CYLINDERS=16   # Cilindros
DISK_SIZE="48M"    # Tamaño total de la imagen del disco

# Crear la imagen de disco con geometría personalizada
qemu-img create -f raw -o $DISK_IMAGEc

# Escribir los binarios en sus sectores respectivos
dd if=$BOOTLOADER_BIN of=$DISK_IMAGE bs=512 count=1 conv=notrunc     # Sector 0 (bootloader)
dd if=$MATRIZ_BIN of=$DISK_IMAGE bs=512 seek=1 conv=notrunc          # Desde el sector 1 al 125
dd if=$TEST_BIN of=$DISK_IMAGE bs=512 seek=126 conv=notrunc          # Sector 126

# Iniciar QEMU con la imagen del disco creada
qemu-system-i386 -fda $DISK_IMAGE
