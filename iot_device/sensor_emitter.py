import requests
import time
import random

# CONFIGURACIÓN
API_URL = "http://localhost:8000/lecturas/" # 
ESTACION_ID = 1  # ID de la estación que queremos simular
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbl9maXNpIiwiZXhwIjoxNzc5ODk5MjMyfQ.3aYcViiOu_WFKU2SHM9HEEUjiLyCgzCnF9RAZqSEmqM"

def leer_sensor_emulado():
    # Simulamos una lectura de nivel de río (10.5 a 85.0 cm) 
    return round(random.uniform(10.5, 85.0), 2)

def enviar_telemetria():
    print(f"--- Iniciando Emisor IoT para Estación {ESTACION_ID} ---") 
    
    while True:
        valor = leer_sensor_emulado() 
        
        payload = { 
            "valor": valor, 
            "estacion_id": ESTACION_ID 
        }
        
        headers = {
            "Authorization": f"Bearer {TOKEN}"
        } 
        
        try:
            response = requests.post(API_URL, json=payload, headers=headers)
            if response.status_code == 200:
                print(f"[OK] Lectura enviada: {valor} cm")
            else:
                print(f"[ERROR] Código: {response.status_code}")
        except Exception as e:
            print(f"[CRÍTICO] No hay conexión con el servidor: {e}")
            
        # LÓGICA DEL RETO: Alerta de Desborde y Frecuencia Dinámica 
        if valor > 70.0: # 
            print("[ALERTA] Umbral de inundación superado.") 
            time.sleep(2)  # Modo de Emergencia
        else:
            time.sleep(10)  # Frecuencia Dinámica normal

if __name__ == "__main__":
    enviar_telemetria()