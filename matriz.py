# Generar un archivo binario con una matriz de 320x200 de un solo color
with open("matriz.bin", "wb") as f:
    for y in range(200):  # 200 filas
        # Calcular el color basado en la fila (y)
        # Usamos un rango de colores de 0 a 255, dividiendo las filas en 7 bandas (arcoíris)
        if y < 28:
            color = 1      # Rojo
        elif y < 56:
            color = 2      # Naranja
        elif y < 84:
            color = 3      # Amarillo
        elif y < 112:
            color = 4      # Verde
        elif y < 140:
            color = 5     # Azul
        elif y < 168:
            color = 6     # Índigo
        else:
            color = 7     # Violeta

        for x in range(320):  # 320 columnas
            f.write(bytes([color]))