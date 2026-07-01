import paho.mqtt.client as mqtt
import requests
import json
import sys
import time
import os 

# CONFIGURACIÓN DEL ENTORNO SMAT
MQTT_BROKER = "broker.hivemq.com"
MQTT_PORT = 1883
MQTT_TOPIC = "unmsm/callao/camara/+/telemetria"
API_URL = os.environ.get("API_URL", "http://127.0.0.1:8000/lecturas/")
JWT_TOKEN = os.environ.get("JWT_TOKEN", "pega_tu_token_aqui_por_si_acaso")

# MEMORIA CACHÉ PARA EL FILTRO DE RUIDO
estacion_cache = {}

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("[+] Conectado exitosamente al Broker MQTT")
        # Suscribirse al tópico global de lecturas de estaciones
        client.subscribe(MQTT_TOPIC)
        print(f"[+] Escuchando transmisiones en el tópico: {MQTT_TOPIC}")
    else:
        print(f"[-] Error de conexión al Broker. Código de retorno: {rc}")
        sys.exit(1)

def on_message(client, userdata, msg):
    try:
        current_time = time.time()
        
        # 1. Decodificar el payload binario de MQTT a JSON string
        payload_raw = msg.payload.decode("utf-8")
        data_json = json.loads(payload_raw)
        
        # 2. Extraer el ID dinámico de la estación desde la estructura del tópico
        topic_parts = msg.topic.split('/')
        estacion_id = int(topic_parts[3])
        nuevo_valor = float(data_json["valor"])
        
        print(f"\n[MQTT] Telemetría recibida de Estación [{estacion_id}]: {nuevo_valor} cm")

        # 3. Filtro de Ruido 
        enviar_api = False
        
        if estacion_id not in estacion_cache:
            # Si es el primer dato de la estación, siempre se envía
            enviar_api = True
            razon_envio = "Primer registro detectado"
        else:
            ultimo_valor = estacion_cache[estacion_id]["valor"]
            ultimo_tiempo = estacion_cache[estacion_id]["timestamp"]
            
            # Calcular variación porcentual
            variacion = abs(nuevo_valor - ultimo_valor) / ultimo_valor if ultimo_valor != 0 else 1.0
            tiempo_transcurrido = current_time - ultimo_tiempo
            
            if variacion > 0.05:
                enviar_api = True
                razon_envio = f"Variación significativa ({(variacion*100):.1f}% > 5%)"
            elif tiempo_transcurrido > 60:
                enviar_api = True
                razon_envio = "Reporte de vida (> 60 segundos)"

        # 4. Ingestión de datos si pasa el filtro
        if enviar_api:
            api_payload = {
                "valor": nuevo_valor,
                "estacion_id": estacion_id
            }
            
            headers = {
                "Content-Type": "application/json",
                "Authorization": f"Bearer {JWT_TOKEN}"
            }
            
            response = requests.post(API_URL, json=api_payload, headers=headers)
            
            if response.status_code == 200 or response.status_code == 201:
                print(f"[HTTP 200] Dato persistido en DB para estación {estacion_id}. Razón: {razon_envio}")
                # Actualizar la caché local solo si se guardó con éxito en la BD
                estacion_cache[estacion_id] = {"valor": nuevo_valor, "timestamp": current_time}
            else:
                print(f"[-] [Fallo de Ingesta] API rechazó el dato. Código: {response.status_code} - {response.text}")
        else:
            print(f"[FILTRO] Dato {nuevo_valor} cm de Estación {estacion_id} bloqueado. No supera umbral de 5% ni timeout de 60s.")

    except KeyError as e:
        print(f"[-] Error de esquema: Falta la llave {e} en el payload MQTT.")
    except ValueError:
        print("[-] Error de casteo: El valor o el ID de la estación no son numéricos.")
    except Exception as e:
        print(f"[-] Error crítico en el Bridge: {e}")

# Inicialización del cliente de red MQTT
bridge_client = mqtt.Client()
bridge_client.on_connect = on_connect
bridge_client.on_message = on_message

try:
    print("Inicializando el Bridge de Acoplamiento SMAT...")
    bridge_client.connect(MQTT_BROKER, MQTT_PORT, 60)
    # Mantener el hilo escuchando activamente de forma síncrona
    bridge_client.loop_forever()
except KeyboardInterrupt:
    print("\nBridge detenido por el administrador.")