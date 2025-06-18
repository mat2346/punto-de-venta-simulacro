import firebase_admin
from firebase_admin import credentials, messaging
import os
import json
from django.conf import settings
import requests

# Verificar si Firebase ya está inicializado
def initialize_firebase():
    if not firebase_admin._apps:
        # Cargar credenciales desde archivo JSON
        try:
            # Usar ruta absoluta al archivo de credenciales
            cred_path = os.path.join(settings.BASE_DIR, 'FIREBASE_CREDENTIALS')
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            print("Firebase inicializado correctamente con archivo de credenciales")
        except Exception as e:
            print(f"Error al inicializar Firebase: {e}")
            return False
    return True

def enviar_notificacion(token, titulo, mensaje, datos=None):
    """
    Enviar notificación a un solo token FCM
    """
    # Inicializar Firebase si aún no se ha hecho
    if not initialize_firebase():
        return {"success": False, "error": "No se pudo inicializar Firebase"}
    
    # Verificar si es un token de prueba
    if token.startswith('token-prueba-'):
        return {
            "success": True, 
            "message_id": f"simulated-{token[:15]}",
            "simulation": True
        }
    
    # Asegurar que datos sea un diccionario
    if datos is None:
        datos = {}
    
    # IMPORTANTE: Duplicar título y mensaje en datos para garantizar entrega
    datos['title'] = titulo
    datos['body'] = mensaje
    datos['click_action'] = 'FLUTTER_NOTIFICATION_CLICK'  # Importante para dispositivos móviles
    
    try:
        # Mensaje de notificación sin el campo webpush.fcm_options.link que causa el error
        mensaje_fcm = messaging.Message(
            token=token,
            notification=messaging.Notification(
                title=titulo,
                body=mensaje,
            ),
            data=datos,
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    sound='default',
                    priority='high',
                    channel_id='high_importance_channel'
                )
            ),
            webpush=messaging.WebpushConfig(
                notification=messaging.WebpushNotification(
                    title=titulo,
                    body=mensaje,
                    icon='/favicon.ico'
                )
                # Quitamos el campo fcm_options que causa el problema
            )
        )
        
        # Enviar mensaje
        response = messaging.send(mensaje_fcm)
        return {"success": True, "message_id": response}
    except Exception as e:
        return {"success": False, "error": str(e)}

def enviar_notificacion_multiple(tokens, titulo, mensaje, datos=None):
    """
    Enviar notificación a múltiples tokens FCM
    """
    # Inicializar Firebase si aún no se ha hecho
    if not initialize_firebase():
        return {"success": False, "error": "No se pudo inicializar Firebase"}
    
    # Verificar tokens válidos
    if not tokens:
        return {"success": False, "error": "No se proporcionaron tokens"}
    
    # Alternativa: Usar HTTP v1 API directamente si tenemos problemas con el SDK
    try:
        # Crear notificación multicast
        mensajes_multicast = [
            messaging.Message(
                token=token,
                notification=messaging.Notification(
                    title=titulo,
                    body=mensaje
                ),
                data=datos or {}
            ) for token in tokens
        ]
        
        # Enviar en batch (máximo 500 mensajes por batch)
        if len(mensajes_multicast) <= 500:
            respuesta = messaging.send_all(mensajes_multicast)
            return {
                "success": respuesta.success_count > 0,
                "success_count": respuesta.success_count,
                "failure_count": respuesta.failure_count,
            }
        else:
            # Para más de 500 tokens, dividir en batches
            resultados = {"success": False, "success_count": 0, "failure_count": 0}
            for i in range(0, len(mensajes_multicast), 500):
                batch = mensajes_multicast[i:i+500]
                respuesta = messaging.send_all(batch)
                resultados["success_count"] += respuesta.success_count
                resultados["failure_count"] += respuesta.failure_count
            
            resultados["success"] = resultados["success_count"] > 0
            return resultados
            
    except Exception as e:
        return {"success": False, "error": str(e)}

