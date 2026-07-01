# Imagen base ligera de Python
FROM python:3.11-slim

# Instalar curl para que el healthcheck funcione
RUN apt-get update && apt-get install -y curl

# Definir el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar los requerimientos e instalarlos
COPY requeriments.txt .
RUN pip install --no-cache-dir -r requeriments.txt

# Copiar el resto del código del backend
COPY . .

# Crear una carpeta dedicada para la base de datos (Persistencia)
RUN mkdir -p /app/data

# Exponer el puerto nativo de FastAPI
EXPOSE 8000

# Comando para arrancar Uvicorn escuchando en todas las interfaces (0.0.0.0)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]