c#!/bin/bash

# Nombre del archivo fuente y binario
SOURCE="test.asm"
OUTPUT="test.bin"

# Paso 1: Ensamblar el archivo con NASM
echo "Compilando $SOURCE..."
nasm -f bin -o $OUTPUT $SOURCE
if [ $? -ne 0 ]; then
    echo "Error: Falló la compilación."
    exit 1
fi
echo "Compilación exitosa: $OUTPUT generado."

# Paso 2: Verificar el tamaño del archivo binario
SIZE=$(stat -c%s "$OUTPUT")
if [ $SIZE -ne 512 ]; then
    echo "Error: El archivo $OUTPUT no tiene el tamaño correcto (512 bytes)."
    exit 1
fi
echo "El archivo $OUTPUT tiene el tamaño correcto (512 bytes)."

# Paso 3: Ejecutar el archivo en QEMU
echo "Ejecutando $OUTPUT en QEMU..."
qemu-system-i386 -drive format=raw,file=$OUTPUT