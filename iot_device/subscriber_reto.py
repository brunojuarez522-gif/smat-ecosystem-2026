import json
import paho.mqtt.client as mqtt
from pydantic import BaseModel, Field, ValidationError

class LecturaSensor(BaseModel):
    sensor_id: int
    timestamp: float
    valor: float = Field(..., ge=-50.0, le=100.0) # Bloquea valores irreales (ej. 150.0)
    unidad: str

BROKER = "broker.hivemq.com"
PUERTO = 1883
TOPICO = "unmsm/callao/camara/+/telemetria"

def on_connect(client, userdata, flags, rc, properties):
    if rc == 0:
        print(f"Conectado. Suscrito al tópico: {TOPICO}")
        client.subscribe(TOPICO)

def on_message(client, userdata, msg):
    raw_payload = msg.payload.decode()
    try:
        datos_json = json.loads(raw_payload)
        lectura = LecturaSensor(**datos_json)

        # Reto: Validar umbral crítico
        if lectura.valor > 5.0:
            print(f"\n[PELIGRO] ¡Pérdida de cadena de frío en Cámara {lectura.sensor_id}! ({lectura.valor}°C)")
        else:
            print(f"[OK] Cámara {lectura.sensor_id} estable a {lectura.valor}°C")

    except (json.JSONDecodeError, ValidationError) as e:
        error_msg = f"ERROR DE INTEGRIDAD en {msg.topic}: {str(e)}\nPayload: {raw_payload}\n---\n"
        print("[ALERTA] Datos corruptos descartados. Escribiendo en log_errores.txt...")
        with open("log_errores.txt", "a") as f:
            f.write(error_msg)

def main():
    cliente = mqtt.Client(callback_api_version=mqtt.CallbackAPIVersion.VERSION2)
    cliente.on_connect = on_connect
    cliente.on_message = on_message
    cliente.connect(BROKER, PUERTO, 60)
    cliente.loop_forever()

if __name__ == "__main__":
    main()