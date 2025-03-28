import numpy as np
from scipy.ndimage import binary_dilation

# Cargar el archivo binario
with open("track_matrix.bin", "rb") as f:
    data = f.read()

# Convertir en matriz de 320x200
matrix = np.frombuffer(data, dtype=np.uint8).reshape((200, 320))

# Crear una copia de la matriz para que sea modificable
matrix = matrix.copy()

# Identificar el carril (valor 0x00)
track_mask = (matrix == 0x00)

# Expandir el carril usando una máscara grande (por ejemplo, 15x15)
expanded_mask = binary_dilation(track_mask, structure=np.ones((15, 15)))

# Aplicar expansión al carril
matrix[expanded_mask] = 0x00

# Guardar resultado en un nuevo archivo
with open("track_matrix_large_track.bin", "wb") as f:
    f.write(matrix.astype(np.uint8).tobytes())
