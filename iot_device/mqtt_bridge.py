import paho.mqtt.client as mqtt
import requests
import json
import time
import threading

BROKER = "broker.hivemq.com"
TOPIC = "fisi/smat/estaciones/#"
API_URL = "http://127.0.0.1:8000/lecturas/"
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbl9maXNpIiwiZXhwIjoxNzgxNjc4NDIzfQ.F1ZKqja_RfLZwvhC9--rrHrdEQB03xApcTwkFP8DRZY" 

last_seen = {}

def check_deadlines():
    while True:
        current_time = time.time()
        for eid, t in list(last_seen.items()):
            if current_time - t > 30:
                print(f"\n[ALERTA OFFLINE] La Estación {eid} no reporta datos hace más de 30s")
        time.sleep(10)

def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode())
        estacion_id = msg.topic.split('/')[-1]
        
        # Registrar el tiempo de vida (Keep-Alive)
        last_seen[estacion_id] = time.time()

        data_to_send = {
            "valor": payload["valor"],
            "estacion_id": int(estacion_id)
        }

        headers = {"Authorization": f"Bearer {TOKEN}"}
        response = requests.post(API_URL, json=data_to_send, headers=headers)

        if response.status_code == 200:
            print(f"[HTTP 200] Dato persistido en DB para estación {estacion_id}")
        else:
            print(f"[ERROR] FastAPI rechazó el dato. Código HTTP {response.status_code}")
            
    except Exception as e:
        print(f"Error procesando mensaje en Bridge: {e}")

def main():
    threading.Thread(target=check_deadlines, daemon=True).start()
    
    client = mqtt.Client()
    client.on_message = on_message
    
    print("Bridge SMAT iniciado. Escuchando MQTT y redirigiendo a HTTP...")
    client.connect(BROKER, 1883)
    client.subscribe(TOPIC)
    client.loop_forever()

if __name__ == "__main__":
    main()