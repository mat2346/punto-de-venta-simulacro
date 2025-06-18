from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
import firebase_admin
from firebase_admin import credentials, messaging
import os
from django.conf import settings
from usuarios.models import Usuario
from libreta.models import Libreta
from materia.models import DetalleMateria # type : ignore
from datetime import datetime

# 🔥 Inicializar Firebase con el archivo de credenciales
if not firebase_admin._apps:
    try:
        firebase_credentials_path = os.getenv("FIREBASE_CREDENTIALS", "secrets/firebase_cred.json")
        if os.path.exists(firebase_credentials_path):
            cred = credentials.Certificate(firebase_credentials_path)
            firebase_admin.initialize_app(cred)
            print("✅ Firebase inicializado correctamente")
        else:
            print(f"⚠️ No se encontró el archivo de credenciales: {firebase_credentials_path}")
    except Exception as e:
        print(f"🔥 Error al inicializar Firebase: {e}")

def enviar_notificacion_firebase(titulo, mensaje, token, datos_extra=None):
    if not token or not isinstance(token, str):
        return {"enviado": False, "motivo": "Token inválido o vacío"}

    try:
        message_data = datos_extra or {}
        
        message = messaging.Message(
            notification=messaging.Notification(
                title=titulo,
                body=mensaje
            ),
            data={str(k): str(v) for k, v in message_data.items()},
            token=token,
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    sound='default',
                    click_action='FLUTTER_NOTIFICATION_CLICK'
                )
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        sound='default',
                        badge=1
                    )
                )
            )
        )

        response = messaging.send(message)
        return {
            "enviado": True,
            "firebase_response": response,
            "motivo": "Enviado correctamente"
        }
    except Exception as e:
        return {"enviado": False, "motivo": f"Error al enviar: {e}"}

def enviar_notificaciones_masivas(usuarios_ids, titulo, mensaje, tipo="general", remitente=None):
    usuarios = Usuario.objects.filter(id__in=usuarios_ids)
    resultados = []
    enviadas = 0
    fallidas = 0
    
    datos_extra = {
        'tipo': tipo,
        'timestamp': datetime.now().isoformat(),
        'remitente_id': str(remitente.id) if remitente else '',
        'remitente_nombre': remitente.nombre if remitente else '',
    }
    
    for usuario in usuarios:
        if usuario.fcm_token and usuario.fcm_token.strip():
            try:
                result = enviar_notificacion_firebase(titulo, mensaje, usuario.fcm_token, datos_extra)
                if result.get('enviado', False):
                    enviadas += 1
                    resultados.append({
                        'usuario_id': usuario.id,
                        'usuario_nombre': usuario.nombre,
                        'success': True
                    })
                else:
                    fallidas += 1
                    resultados.append({
                        'usuario_id': usuario.id,
                        'usuario_nombre': usuario.nombre,
                        'success': False,
                        'error': result.get('motivo', 'Error desconocido')
                    })
            except Exception as e:
                fallidas += 1
                resultados.append({
                    'usuario_id': usuario.id,
                    'usuario_nombre': usuario.nombre,
                    'success': False,
                    'error': str(e)
                })
        else:
            fallidas += 1
            resultados.append({
                'usuario_id': usuario.id,
                'usuario_nombre': usuario.nombre,
                'success': False,
                'error': 'Sin token FCM'
            })
    
    return {
        'success': True,
        'enviadas': enviadas,
        'fallidas': fallidas,
        'total': len(usuarios),
        'detalles': resultados
    }

def obtener_destinatarios_notificacion(detalle_materia_id=None):
    estudiantes = []
    tutores = []
    materia_info = None
    
    if detalle_materia_id:
        try:
            detalle_materia = DetalleMateria.objects.get(id=detalle_materia_id) #type : ignore[attr-degined]
            materia_info = {
                'id': detalle_materia.id,
                'nombre': detalle_materia.materia.nombre,
            }
            
            libretas = Libreta.objects.filter(detalle_materia=detalle_materia)
            tutores_agregados = set()
            
            for libreta in libretas:
                estudiante = libreta.estudiante
                estudiantes.append({
                    'id': estudiante.id,
                    'nombre': estudiante.nombre,
                    'codigo': estudiante.codigo,
                    'tiene_fcm_token': bool(estudiante.fcm_token and estudiante.fcm_token.strip()),
                })
                
                if estudiante.tutor and estudiante.tutor.id not in tutores_agregados:
                    tutor = estudiante.tutor
                    tutores.append({
                        'id': tutor.id,
                        'nombre': tutor.nombre,
                        'codigo': tutor.codigo,
                        'tiene_fcm_token': bool(tutor.fcm_token and tutor.fcm_token.strip()),
                        'estudiante_asociado': estudiante.nombre,
                    })
                    tutores_agregados.add(tutor.id)
        except DetalleMateria.DoesNotExist:
            return None
    else:
        estudiantes_usuarios = Usuario.objects.filter(rol__nombre='estudiante', estado=True)
        tutores_usuarios = Usuario.objects.filter(rol__nombre='tutor', estado=True)
        
        estudiantes = [{
            'id': u.id,
            'nombre': u.nombre,
            'codigo': u.codigo,
            'tiene_fcm_token': bool(u.fcm_token and u.fcm_token.strip()),
        } for u in estudiantes_usuarios]
        
        tutores = [{
            'id': u.id,
            'nombre': u.nombre,
            'codigo': u.codigo,
            'tiene_fcm_token': bool(u.fcm_token and u.fcm_token.strip()),
        } for u in tutores_usuarios]
    
    return {
        'estudiantes': estudiantes,
        'tutores': tutores,
        'materia_info': materia_info
    }

# ==================== ENDPOINTS ====================

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def crear_notificacion_uni(request, id):
    try:
        usuario = Usuario.objects.get(id=id)
    except Usuario.DoesNotExist:
        return Response(
            {"mensaje": "Usuario no encontrado"}, 
            status=status.HTTP_400_BAD_REQUEST
        )

    data = request.data.copy()
    titulo = data.get("titulo", "Notificación")
    mensaje = data.get("mensaje", "")
    firebase_resultado = {"enviado": False, "motivo": ""}

    if usuario.fcm_token and usuario.fcm_token.strip():
        try:
            res = enviar_notificacion_firebase(titulo, mensaje, usuario.fcm_token)
            firebase_resultado = {
                "enviado": res.get("enviado", False),
                "motivo": res.get("motivo", "OK" if res.get("enviado") else "Sin motivo")
            }
        except Exception as e:
            firebase_resultado = {
                "enviado": False,
                "motivo": f"Error al enviar: {str(e)}"
            }
    else:
        firebase_resultado["motivo"] = "Usuario sin token FCM"

    return Response({
        "mensaje": "Notificación creada",
        "firebase": firebase_resultado
    }, status=status.HTTP_201_CREATED)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def enviar_notificacion_masiva(request):
    if not request.user.rol or request.user.rol.nombre.lower() != 'profesor':
        return Response({'error': 'Solo los profesores pueden enviar notificaciones'}, 
                      status=status.HTTP_403_FORBIDDEN)
    
    destinatarios_ids = request.data.get('destinatarios', [])
    titulo = request.data.get('titulo', '')
    mensaje = request.data.get('mensaje', '')
    tipo = request.data.get('tipo', 'general')
    
    if not destinatarios_ids or not titulo or not mensaje:
        return Response({'error': 'Destinatarios, título y mensaje son requeridos'}, 
                      status=status.HTTP_400_BAD_REQUEST)
    
    resultado = enviar_notificaciones_masivas(destinatarios_ids, titulo, mensaje, tipo, request.user)
    resultado['profesor'] = {'id': request.user.id, 'nombre': request.user.nombre}
    
    return Response(resultado, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def obtener_destinatarios(request):
    detalle_materia_id = request.query_params.get('detalle_materia_id')
    
    if detalle_materia_id:
        try:
            detalle_materia_id = int(detalle_materia_id)
        except ValueError:
            return Response({'error': 'ID de materia inválido'}, 
                          status=status.HTTP_400_BAD_REQUEST)
    
    resultado = obtener_destinatarios_notificacion(detalle_materia_id)
    
    if resultado is None:
        return Response({'error': 'Materia no encontrada'}, 
                      status=status.HTTP_404_NOT_FOUND)
    
    return Response(resultado, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def enviar_notificacion_simple(request, usuario_id):
    try:
        usuario = Usuario.objects.get(id=usuario_id)
    except Usuario.DoesNotExist:
        return Response({'error': 'Usuario no encontrado'}, 
                      status=status.HTTP_404_NOT_FOUND)
    
    titulo = request.data.get('titulo', 'Notificación')
    mensaje = request.data.get('mensaje', '')
    
    if not mensaje:
        return Response({'error': 'El mensaje es requerido'}, 
                      status=status.HTTP_400_BAD_REQUEST)
    
    datos_extra = {
        'tipo': request.data.get('tipo', 'general'),
        'remitente_id': str(request.user.id),
        'remitente_nombre': request.user.nombre,
        'timestamp': datetime.now().isoformat(),
    }
    
    firebase_resultado = {"enviado": False, "motivo": ""}
    
    if usuario.fcm_token and usuario.fcm_token.strip():
        try:
            res = enviar_notificacion_firebase(titulo, mensaje, usuario.fcm_token, datos_extra)
            firebase_resultado = {
                "enviado": res.get("enviado", False),
                "motivo": res.get("motivo", "OK" if res.get("enviado") else "Sin motivo")
            }
        except Exception as e:
            firebase_resultado = {"enviado": False, "motivo": f"Error: {str(e)}"}
    else:
        firebase_resultado["motivo"] = "Usuario sin token FCM"
    
    return Response({
        "mensaje": "Notificación procesada",
        "usuario": {"id": usuario.id, "nombre": usuario.nombre},
        "firebase": firebase_resultado,
        "remitente": {"id": request.user.id, "nombre": request.user.nombre}
    }, status=status.HTTP_200_OK)

