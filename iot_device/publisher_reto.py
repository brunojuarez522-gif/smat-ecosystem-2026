import time
import random
import json
import paho.mqtt.client as mqtt

BROKER = "broker.hivemq.com"
PUERTO = 1883

def conectar_mqtt():
    client = mqtt.Client(callback_api_version=mqtt.CallbackAPIVersion.VERSION2)
    client.connect(BROKER, PUERTO, 60)
    return client

def main():
    cliente = conectar_mqtt()
    cliente.loop_start()
    try:
        while True:
            for camara_id in [1, 2]:
                # Tópico dinámico con el ID de la cámara
                topico = f"unmsm/callao/camara/{camara_id}/telemetria"

                # Fallas aleatorias: 15% de probabilidad de error
                if random.random() < 0.15:
                    temperatura = "ERROR_HARDWARE" if random.choice([True, False]) else 150.0
                else:
                    # Temperatura normal de operación (entre -2 y 7 grados)
                    temperatura = round(random.uniform(-2.0, 7.0), 2)

                datos_sensor = {
                    "sensor_id": camara_id,
                    "timestamp": time.time(),
                    "valor": temperatura,
                    "unidad": "Celsius"
                }

                mensaje = json.dumps(datos_sensor)
                cliente.publish(topico, mensaje, qos=1)
                print(f"[PUBLISHER] Enviado a {topico}: {mensaje}")
                time.sleep(2)
    except KeyboardInterrupt:
        print("\nDeteniendo publicador...")
    finally:
        cliente.loop_stop()
        cliente.disconnect()

if __name__ == "__main__":
    main()