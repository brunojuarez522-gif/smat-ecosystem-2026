# Imagen base
FROM python:3.11-slim

# Directorio de trabajo
WORKDIR /app

# Instalar las librerias
RUN pip install paho-mqtt requests

# Copiar el script del puente
COPY mqtt_bridge.py .

# Ejecutar el daemon
CMD ["python", "mqtt_bridge.py"]