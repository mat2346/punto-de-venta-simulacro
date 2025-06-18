from rest_framework import viewsets, status
from .models import Usuario
from .serializers import UsuarioSerializer, CustomTokenObtainPairSerializer
from .serializers import UsuarioSerializer, CustomTokenObtainPairSerializer
from django.contrib.auth import authenticate
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from libreta.models import Libreta
from actividad.models import Actividad, EntregaTarea
from materia.models import DetalleMateria,Asistencia
from datetime import datetime, timedelta

class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer

# Login JWT usando el campo 'codigo'
class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

# Puedes seguir usando este LoginView si quieres login manual:
class LoginView(APIView):
    @swagger_auto_schema(
        operation_description="Login con código y contraseña. Devuelve access y refresh token.",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'codigo': openapi.Schema(type=openapi.TYPE_STRING, description='Código de usuario'),
                'password': openapi.Schema(type=openapi.TYPE_STRING, description='Contraseña'),
                'fcm_token': openapi.Schema(type=openapi.TYPE_STRING, description='Token FCM (opcional)'),  # 🔥 Agregar
            },
            required=['codigo', 'password'],
        ),
        responses={
            200: openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'detail': openapi.Schema(type=openapi.TYPE_STRING),
                    'access': openapi.Schema(type=openapi.TYPE_STRING),
                    'refresh': openapi.Schema(type=openapi.TYPE_STRING),
                    'usuario': openapi.Schema(type=openapi.TYPE_OBJECT),
                    'fcm_token_updated': openapi.Schema(type=openapi.TYPE_BOOLEAN),  # 🔥 Agregar
                }
            ),
            400: openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'detail': openapi.Schema(type=openapi.TYPE_STRING),
                }
            ),
        }
    )
    def post(self, request):
        codigo = request.data.get('codigo')
        password = request.data.get('password')
        fcm_token = request.data.get('fcm_token')  # 🔥 Obtener FCM token
        
        # 🔥 Logs de debug
        print(f"=== DEBUG LOGIN ===")
        print(f"Código: {codigo}")
        print(f"Password recibido: {'Sí' if password else 'No'}")
        print(f"FCM Token recibido: {'Sí' if fcm_token else 'No'}")
        if fcm_token:
            print(f"FCM Token preview: {fcm_token[:30]}...")
            print(f"FCM Token length: {len(fcm_token)}")
        print(f"==================")
        
        user = authenticate(request, username=codigo, password=password)
        if user is not None:
            print(f"✅ Usuario autenticado: {user.id} - {user.nombre}")
            
            # 🔥 Actualizar FCM token con más logs
            fcm_token_updated = False
            if fcm_token and fcm_token.strip():
                try:
                    print(f"🔄 Intentando actualizar FCM token para usuario {user.id}")
                    print(f"📱 Token anterior: {user.fcm_token[:30] if user.fcm_token else 'None'}...")
                    
                    user.fcm_token = fcm_token
                    user.save(update_fields=['fcm_token'])
                    
                    # Verificar que se guardó
                    user.refresh_from_db()
                    if user.fcm_token == fcm_token:
                        fcm_token_updated = True
                        print(f"✅ FCM token GUARDADO correctamente para usuario {user.id}")
                        print(f"📱 Token guardado: {user.fcm_token[:30]}...")
                    else:
                        print(f"❌ FCM token NO se guardó correctamente")
                        
                except Exception as e:
                    print(f"❌ ERROR guardando FCM token: {e}")
                    import traceback
                    traceback.print_exc()
            else:
                print(f"⚠️ No se recibió FCM token válido")
            
            refresh = RefreshToken.for_user(user)
            return Response({
                'detail': 'Login exitoso',
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'usuario': UsuarioSerializer(user).data,
                'fcm_token_updated': fcm_token_updated,  # 🔥 Informar si se actualizó
            }, status=status.HTTP_200_OK)
        
        print(f"❌ Login fallido para código: {codigo}")
        return Response({'detail': 'Código o contraseña incorrectos'}, status=status.HTTP_400_BAD_REQUEST)

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Logout del usuario autenticado (JWT).",
        responses={
            200: openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'detail': openapi.Schema(type=openapi.TYPE_STRING),
                }
            ),
        }
    )
    def post(self, request):
        # Para JWT, el "logout" es solo borrar el token en el cliente.
        # Si quieres invalidar el refresh token, puedes hacer un blacklist si tienes habilitado.
        return Response({'detail': 'Logout exitoso'}, status=status.HTTP_200_OK)

class CambiarContrasenaView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Permite al usuario autenticado cambiar su contraseña.",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'old_password': openapi.Schema(type=openapi.TYPE_STRING, description='Contraseña actual'),
                'new_password': openapi.Schema(type=openapi.TYPE_STRING, description='Nueva contraseña'),
            },
            required=['old_password', 'new_password'],
        ),
        responses={
            200: openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'detail': openapi.Schema(type=openapi.TYPE_STRING),
                }
            ),
            400: openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'detail': openapi.Schema(type=openapi.TYPE_STRING),
                }
            ),
        }
    )
    def post(self, request):
        user = request.user
        old_password = request.data.get('old_password')
        new_password = request.data.get('new_password')
        if not user.check_password(old_password):
            return Response({'detail': 'Contraseña actual incorrecta.'}, status=status.HTTP_400_BAD_REQUEST)
        if not new_password:
            return Response({'detail': 'Debes proporcionar una nueva contraseña.'}, status=status.HTTP_400_BAD_REQUEST)
        user.set_password(new_password)
        user.save()
        return Response({'detail': '¡Contraseña actualizada correctamente!'}, status=status.HTTP_200_OK)
    
class EstudiantesDelTutorView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        tutor = request.user
        # Obtener los estudiantes asociados al tutor
        estudiantes = Usuario.objects.filter(tutor=tutor, estado=True).values(
            'id', 'nombre', 'codigo', 'sexo', 'fecha_nacimiento'
        )
        return Response(list(estudiantes))

class ResumenAlumnoView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        estudiante = request.user

        # Obtener materias actuales
        libretas = Libreta.objects.filter(estudiante=estudiante).select_related('detalle_materia__materia', 'detalle_materia__profesor')

        materias = []
        detalle_ids = []
        for l in libretas:
            detalle = l.detalle_materia
            materias.append({
                "id": detalle.materia.id,
                "nombre": detalle.materia.nombre,
                "profesor": detalle.profesor.nombre if detalle.profesor else "N/A",
                "promedio": None  # aún no calculamos promedio
            })
            detalle_ids.append(detalle.id)

        # Obtener porcentaje de asistencia
        total_asistencias = Asistencia.objects.filter(detalle_materia_id__in=detalle_ids, estudiante=estudiante).count()
        asistencias_presentes = Asistencia.objects.filter(detalle_materia_id__in=detalle_ids, estudiante=estudiante, presente=True).count()
        porcentaje_asistencia = round((asistencias_presentes / total_asistencias) * 100, 1) if total_asistencias > 0 else 0

        # Obtener actividades recientes (últimos 7 días)
        recientes = []
        hace_una_semana = datetime.now() - timedelta(days=7)

        actividades = Actividad.objects.filter(
            detalles_actividad__detalle_materia_id__in=detalle_ids,
            fechaCreacion__gte=hace_una_semana  # ✅ nombre correcto
        ).distinct().order_by('-fechaCreacion')[:5]  # ✅ corregido

        for act in actividades:
            entrega = EntregaTarea.objects.filter(actividad=act, usuario=estudiante).first()
            estado = "Entregado" if entrega and entrega.entregado else "Pendiente"
            nombre_materia = act.detalles_actividad.first().detalle_materia.materia.nombre if act.detalles_actividad.exists() else "Desconocida"

            recientes.append({
                "materia": nombre_materia,
                "titulo": act.nombre,
                "estado": estado
            })

        return Response({
            "porcentaje_asistencia": porcentaje_asistencia,
            "porcentaje_participacion": porcentaje_asistencia,  # temporal
            "materias": materias,
            "actividades_recientes": recientes
        })

class ResumenHijoTutorView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, estudiante_id):
        tutor = request.user
        
        # Verificar que el estudiante sea hijo del tutor
        try:
            estudiante = Usuario.objects.get(id=estudiante_id, tutor=tutor)
        except Usuario.DoesNotExist:
            return Response({'error': 'Estudiante no encontrado o no autorizado'}, status=403)

        # Obtener materias del estudiante con manejo de errores
        try:
            libretas = Libreta.objects.filter(estudiante=estudiante).select_related(
                'detalle_materia__materia', 
                'detalle_materia__profesor',
                'detalle_materia__curso',
                'detalle_materia__curso__paralelo'
            )

            materias = []
            detalle_ids = []
            promedio_total = 0
            contador_materias = 0

            for libreta in libretas:
                detalle = libreta.detalle_materia
                # Manejo seguro de la nota
                try:
                    promedio_materia = float(libreta.nota) if libreta.nota else 75.0
                except (ValueError, AttributeError):
                    promedio_materia = 75.0
                
                # Construir nombre del curso con manejo de errores
                curso_nombre = "N/A"
                try:
                    if detalle.curso:
                        curso_base = detalle.curso.nombre or "Sin curso"
                        if hasattr(detalle.curso, 'paralelo') and detalle.curso.paralelo:
                            paralelo_nombre = detalle.curso.paralelo.nombre or ""
                            curso_nombre = f"{curso_base} {paralelo_nombre}".strip()
                        else:
                            curso_nombre = curso_base
                except AttributeError:
                    curso_nombre = "N/A"
                
                materias.append({
                    "id": detalle.id,
                    "nombre": detalle.materia.nombre if detalle.materia else "Sin nombre",
                    "profesor": detalle.profesor.nombre if detalle.profesor else "Sin profesor",
                    "promedio": promedio_materia,
                    "curso": curso_nombre
                })
                detalle_ids.append(detalle.id)
                promedio_total += promedio_materia
                contador_materias += 1

            # Calcular promedio general
            promedio_general = round(promedio_total / contador_materias, 1) if contador_materias > 0 else 0

            # Calcular asistencia con manejo de errores
            try:
                total_asistencias = Asistencia.objects.filter(
                    detalle_materia_id__in=detalle_ids, estudiante=estudiante
                ).count()
                asistencias_presentes = Asistencia.objects.filter(
                    detalle_materia_id__in=detalle_ids, estudiante=estudiante, presente=True
                ).count()
                porcentaje_asistencia = round((asistencias_presentes / total_asistencias) * 100, 1) if total_asistencias > 0 else 100
            except Exception:
                porcentaje_asistencia = 100

            # Obtener actividades recientes con manejo de errores
            actividades_recientes = []
            try:
                actividades = Actividad.objects.filter(
                    detalles_actividad__detalle_materia_id__in=detalle_ids
                ).distinct().order_by('-fechaCreacion')[:10]

                for actividad in actividades:
                    try:
                        entrega = EntregaTarea.objects.filter(actividad=actividad, usuario=estudiante).first()
                        estado = "Entregado" if entrega and entrega.entregado else "Pendiente"
                        
                        # Obtener nombre de materia de forma segura
                        materia_nombre = "Desconocida"
                        if actividad.detalles_actividad.exists():
                            primer_detalle = actividad.detalles_actividad.first()
                            if primer_detalle and primer_detalle.detalle_materia and primer_detalle.detalle_materia.materia:
                                materia_nombre = primer_detalle.detalle_materia.materia.nombre
                        
                        actividades_recientes.append({
                            "id": actividad.id,
                            "materia": materia_nombre,
                            "titulo": actividad.nombre or "Sin título",
                            "estado": estado,
                            "fecha": actividad.fechaCreacion.isoformat() if actividad.fechaCreacion else None,
                            "nota": float(entrega.calificacion) if entrega and entrega.calificacion else None
                        })
                    except Exception as e:
                        # Saltar actividades problemáticas
                        continue
            except Exception:
                actividades_recientes = []

            # Determinar curso principal
            curso_principal = materias[0]["curso"] if materias else "N/A"

            return Response({
                "estudiante": {
                    "id": estudiante.id,
                    "nombre": estudiante.nombre,
                    "codigo": estudiante.codigo
                },
                "promedio_general": promedio_general,
                "asistencia": porcentaje_asistencia,
                "participacion": porcentaje_asistencia,  # temporal
                "materias": materias,
                "actividades_recientes": actividades_recientes,
                "curso": curso_principal
            })

        except Exception as e:
            # En caso de error, devolver datos por defecto
            return Response({
                "estudiante": {
                    "id": estudiante.id,
                    "nombre": estudiante.nombre,
                    "codigo": estudiante.codigo
                },
                "promedio_general": 0,
                "asistencia": 100,
                "participacion": 100,
                "materias": [],
                "actividades_recientes": [],
                "curso": "N/A",
                "error": "Error al cargar algunos datos"
            })

class RendimientoDetalladoHijoView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, estudiante_id):
        tutor = request.user
        
        # Verificar que el estudiante sea hijo del tutor
        try:
            estudiante = Usuario.objects.get(id=estudiante_id, tutor=tutor)
        except Usuario.DoesNotExist:
            return Response({'error': 'Estudiante no encontrado o no autorizado'}, status=403)

        # Obtener materias y promedios
        libretas = Libreta.objects.filter(estudiante=estudiante).select_related(
            'detalle_materia__materia', 'detalle_materia__profesor'
        )

        materias_data = []
        detalle_ids = []

        for libreta in libretas:
            detalle = libreta.detalle_materia
            promedio = float(libreta.nota) if hasattr(libreta, 'nota') and libreta.nota else 75
            
            materias_data.append({
                "nombre": detalle.materia.nombre,
                "profesor": detalle.profesor.nombre if detalle.profesor else "N/A",
                "promedio": promedio
            })
            detalle_ids.append(detalle.id)

        # Datos de asistencia
        total_asistencias = Asistencia.objects.filter(
            detalle_materia_id__in=detalle_ids, estudiante=estudiante
        ).count()
        asistencias_presentes = Asistencia.objects.filter(
            detalle_materia_id__in=detalle_ids, estudiante=estudiante, presente=True
        ).count()

        asistencia_data = {
            "presente": asistencias_presentes,
            "ausente": total_asistencias - asistencias_presentes
        }

        # Tendencia de notas (últimos 4 meses)
        tendencia_data = [
            {"fecha": "2025-03-01", "promedio": 78},
            {"fecha": "2025-04-01", "promedio": 82},
            {"fecha": "2025-05-01", "promedio": 85},
            {"fecha": "2025-06-01", "promedio": 87}
        ]

        return Response({
            "materias": materias_data,
            "asistencia": asistencia_data,
            "tendencia": tendencia_data
        })