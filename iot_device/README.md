## Proyecto SMAT - Emulador de Telemetría IoT

Este proyecto contiene un script en Python que simula un sensor físico de nivel de agua. Su función es enviar datos de telemetría de forma autónoma al servidor.

## Comunicación y Seguridad
El dispositivo envía los datos de forma independiente, sin requerir la intervención de un usuario. El flujo es el siguiente:

* **Token JWT:** El script utiliza un token de seguridad fijo que se obtiene del backend.
* **Envío de datos:** Cada lectura del sensor se envía al servidor mediante una petición HTTP POST.
* **Autorización:** El token viaja en las cabeceras de la petición (Authorization: Bearer). Esto permite que el servidor valide la identidad del dispositivo antes de procesar y guardar la información.

## Reglas del Reto de Inundación
El script modifica automáticamente su velocidad de envío dependiendo del nivel del agua detectado:

* **Estado Normal (<= 70.0 cm):** Envía datos cada 10 segundos.
* **Estado de Alerta (>70.0 cm):** Muestra el mensaje "[ALERTA] Umbral de inundación superado" en la consola y aumenta la velocidad de envío a cada 2 segundos.