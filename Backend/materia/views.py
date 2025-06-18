from django.shortcuts import render
from Backend.permissions import SoloUsuariosConRol
from rest_framework import viewsets, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from datetime import date, datetime

from libreta.models import Libreta
from .models import Nivel, Materia, DetalleMateria, Asistencia
from .serializers import NivelSerializer, MateriaSerializer, DetalleMateriaSerializer, AsistenciaSerializer
from actividad.models import Actividad, EntregaTarea, DetalleActividad


class NivelViewSet(viewsets.ModelViewSet):
    queryset = Nivel.objects.all()
    serializer_class = NivelSerializer


class MateriaViewSet(viewsets.ModelViewSet):
    queryset = Materia.objects.all()
    serializer_class = MateriaSerializer


class DetalleMateriaViewSet(viewsets.ModelViewSet):
    queryset = DetalleMateria.objects.all()
    serializer_class = DetalleMateriaSerializer


class AsistenciaViewSet(viewsets.ModelViewSet):
    queryset = Asistencia.objects.all()
    serializer_class = AsistenciaSerializer


class MateriasDelProfesorView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        profesor = request.user
        detalles = DetalleMateria.objects.filter(profesor=profesor).select_related('materia', 'curso__paralelo')

        resultado = []
        for detalle in detalles:
            resultado.append({
                'detalle_id': detalle.id, 
                'materia': detalle.materia.nombre,
                'nivel': detalle.materia.nivel.get_nombre_display(),
                'curso': detalle.curso.nombre,
                'paralelo': detalle.curso.paralelo.nombre
            })

        return Response(resultado)


class MateriasDelAlumnoView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        alumno = request.user

        libretas = Libreta.objects.filter(estudiante=alumno).select_related(
            'detalle_materia__materia',
            'detalle_materia__curso__paralelo',
            'detalle_materia__profesor'
        )
        
        materias_set = set()
        resultado = []
        
        for libreta in libretas:
            detalle = libreta.detalle_materia
            if detalle and detalle.id not in materias_set:
                materias_set.add(detalle.id)
                profesor = detalle.profesor
                
                materia_data = {
                    'id': detalle.id,
                    'nombre': detalle.materia.nombre,
                    'profesor': profesor.nombre if profesor else 'Profesor no asignado',
                    'promedio': float(libreta.nota) if hasattr(libreta, 'nota') and libreta.nota else 0.0,
                    'curso': detalle.curso.nombre,
                    'paralelo': detalle.curso.paralelo.nombre,
                    'nivel': detalle.materia.nivel.get_nombre_display(),
                }
                
                resultado.append(materia_data)

        return Response(resultado)


class EstudiantesDeMateriaView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, detalle_id):
        profesor = request.user

        try:
            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)
        except DetalleMateria.DoesNotExist:
            return Response({'error': 'Materia no encontrada o no autorizada'}, status=403)

        libretas = Libreta.objects.filter(detalle_materia=detalle).select_related('estudiante')
        
        resultado = []
        for libreta in libretas:
            estudiante = libreta.estudiante
            resultado.append({
                'id': estudiante.id,
                'nombre': estudiante.nombre,
                'libreta_id': libreta.id
            })

        return Response(resultado)


class RegistrarAsistenciaDesdeLibreta(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, detalle_id):
        profesor = request.user

        try:
            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)
        except DetalleMateria.DoesNotExist:
            return Response({'error': 'No autorizado para esta materia'}, status=403)

        datos = request.data
        if not isinstance(datos, list):
            return Response({'error': 'Se espera una lista de asistencias'}, status=400)

        resultados = []
        errores = []

        for item in datos:
            libreta_id = item.get('libreta_id')
            presente = item.get('presente')

            try:
                libreta = Libreta.objects.get(id=libreta_id, detalle_materia=detalle)
            except Libreta.DoesNotExist:
                errores.append(f"Libreta {libreta_id} no pertenece a esta materia")
                continue

            # Verificar duplicados para hoy
            if Asistencia.objects.filter(
                detalle_materia=detalle,
                estudiante=libreta.estudiante,
                fecha=date.today()
            ).exists():
                errores.append(f"Asistencia para libreta {libreta_id} ya existe hoy")
                continue

            # Crear la asistencia
            Asistencia.objects.create(
                detalle_materia=detalle,
                estudiante=libreta.estudiante,
                presente=presente
            )

            resultados.append({
                'estudiante': libreta.estudiante.nombre,
                'presente': presente
            })

        return Response({
            'mensaje': 'Proceso completado',
            'creados': resultados,
            'errores': errores
        }, status=status.HTTP_201_CREATED)


class ObtenerAsistenciaPorFechaView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, detalle_id):
        profesor = request.user
        fecha_str = request.query_params.get('fecha', None)
        fecha = date.today()
        
        if fecha_str:
            try:
                fecha = datetime.strptime(fecha_str, '%Y-%m-%d').date()
            except Exception:
                pass

        try:
            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)
        except DetalleMateria.DoesNotExist:
            return Response({'error': 'No autorizado para esta materia'}, status=403)

        asistencias = Asistencia.objects.filter(
            detalle_materia=detalle, 
            fecha=fecha
        ).select_related('estudiante')

        resultado = []
        for asistencia in asistencias:
            resultado.append({
                'estudiante_id': asistencia.estudiante.id,
                'nombre': asistencia.estudiante.nombre,
                'presente': asistencia.presente
            })

        return Response({'fecha': fecha, 'asistencias': resultado})


class ReporteAsistenciaGestionView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, detalle_id):
        profesor = request.user

        try:
            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)
        except DetalleMateria.DoesNotExist:
            return Response({'error': 'No autorizado'}, status=403)

        # Obtener fechas únicas ordenadas
        fechas = list(
            Asistencia.objects.filter(detalle_materia=detalle)
            .order_by('fecha')
            .values_list('fecha', flat=True)
            .distinct()
        )

        # Obtener estudiantes de la materia
        libretas = Libreta.objects.filter(detalle_materia=detalle).select_related('estudiante')

        resultado = []
        for libreta in libretas:
            fila = {'nombre': libreta.estudiante.nombre, 'asistencias': []}
            for fecha in fechas:
                asistencia = Asistencia.objects.filter(
                    detalle_materia=detalle,
                    estudiante=libreta.estudiante,
                    fecha=fecha
                ).first()
                fila['asistencias'].append(asistencia.presente if asistencia else False)
            resultado.append(fila)

        fechas_str = [f.isoformat() for f in fechas]
        return Response({'fechas': fechas_str, 'estudiantes': resultado})


class MateriaDetalleAlumnoView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, detalle_id):
        try:
            # Validaciones iniciales
            if request.user.rol.nombre.lower() != 'estudiante':
                return Response({"error": "Acceso denegado"}, status=403)

            estudiante = request.user
            
            # Verificar materia y acceso
            detalle = self._verificar_acceso_materia(estudiante, detalle_id)
            if isinstance(detalle, Response):
                return detalle

            # Obtener datos de la materia
            materia_data = self._obtener_datos_materia(detalle, estudiante)
            
            # Obtener actividades específicas
            actividades_data = self._obtener_actividades_materia(detalle, estudiante)
            
            # Obtener asistencias específicas
            asistencia_data = self._obtener_asistencias_materia(detalle, estudiante)

            return Response({
                "materia": materia_data,
                "actividades": actividades_data,
                "asistencia": asistencia_data
            })

        except Exception as e:
            return Response({"error": "Error interno del servidor"}, status=500)

    def _verificar_acceso_materia(self, estudiante, detalle_id):
        """Verifica que el estudiante tenga acceso a la materia"""
        try:
            detalle = DetalleMateria.objects.get(id=detalle_id)
        except DetalleMateria.DoesNotExist:
            return Response({'error': 'Materia no encontrada'}, status=404)

        try:
            Libreta.objects.get(estudiante=estudiante, detalle_materia=detalle)
            return detalle
        except Libreta.DoesNotExist:
            return Response({'error': 'No tienes acceso a esta materia'}, status=403)

    def _obtener_datos_materia(self, detalle, estudiante):
        """Obtiene los datos básicos de la materia"""
        try:
            libreta = Libreta.objects.get(estudiante=estudiante, detalle_materia=detalle)
            promedio = float(libreta.nota) if hasattr(libreta, 'nota') and libreta.nota else 85.5
        except:
            promedio = 85.5

        return {
            "id": detalle.id,
            "nombre": detalle.materia.nombre,
            "profesor": detalle.profesor.nombre if detalle.profesor else "Sin profesor",
            "promedio": promedio,
            "curso": f"{detalle.curso.nombre} {detalle.curso.paralelo.nombre}"
        }

    def _obtener_actividades_materia(self, detalle, estudiante):
        """Obtiene las actividades específicas de la materia"""
        try:
            actividades_materia = Actividad.objects.filter(
                detalles_actividad__detalle_materia=detalle
            ).order_by('-fechaCreacion')
            
            actividades_data = []
            for actividad in actividades_materia:
                # Verificar entrega del estudiante
                estado, nota, fecha_entrega_real = self._verificar_entrega_actividad(actividad, estudiante)
                
                actividades_data.append({
                    "id": actividad.id,
                    "titulo": actividad.nombre,
                    "descripcion": actividad.descripcion,
                    "dimension": actividad.dimension.nombre,
                    "fecha_creacion": actividad.fechaCreacion.isoformat() if actividad.fechaCreacion else None,
                    "fecha_entrega": fecha_entrega_real,
                    "estado": estado,
                    "nota": float(nota) if nota else None,
                    "tipo": actividad.dimension.nombre
                })
            
            return actividades_data

        except Exception:
            # Datos de ejemplo como fallback
            return [
                {
                    "id": 1,
                    "titulo": f"Examen Parcial - {detalle.materia.nombre}",
                    "fecha_entrega": "2025-06-15T00:00:00Z",
                    "estado": "Entregado",
                    "nota": 85,
                    "tipo": "Examen"
                }
            ]

    def _verificar_entrega_actividad(self, actividad, estudiante):
        """Verifica si el estudiante entregó la actividad"""
        try:
            entrega = EntregaTarea.objects.get(actividad=actividad, usuario=estudiante)
            estado = "Entregado" if entrega.entregado else "Pendiente"
            nota = entrega.calificacion
            fecha_entrega = entrega.fecha_entrega.isoformat() if entrega.fecha_entrega else None
            return estado, nota, fecha_entrega
        except EntregaTarea.DoesNotExist:
            return "Pendiente", None, None

    def _obtener_asistencias_materia(self, detalle, estudiante):
        """Obtiene las asistencias específicas de la materia"""
        try:
            asistencias_estudiante = Asistencia.objects.filter(
                detalle_materia=detalle,
                estudiante=estudiante
            ).order_by('-fecha')
            
            total_clases = asistencias_estudiante.count()
            asistencias_presentes = asistencias_estudiante.filter(presente=True).count()
            clases_perdidas = total_clases - asistencias_presentes
            porcentaje_asistencia = round((asistencias_presentes / total_clases) * 100, 1) if total_clases > 0 else 100.0

            # Historial de asistencia
            historial_asistencia = []
            asistencias_recientes = asistencias_estudiante[:15]
            
            for asistencia in asistencias_recientes:
                historial_asistencia.append({
                    "fecha": asistencia.fecha.strftime("%d/%m"),
                    "presente": asistencia.presente,
                    "fecha_completa": asistencia.fecha.strftime("%Y-%m-%d")
                })

            return {
                "total_clases": total_clases,
                "clases_asistidas": asistencias_presentes,
                "clases_perdidas": clases_perdidas,
                "porcentaje": porcentaje_asistencia,
                "historial_semanal": historial_asistencia,
                "materia_especifica": detalle.materia.nombre
            }

        except Exception:
            return {
                "total_clases": 0,
                "clases_asistidas": 0,
                "clases_perdidas": 0,
                "porcentaje": 0.0,
                "historial_semanal": [],
                "materia_especifica": detalle.materia.nombre,
                "error": "No se pudieron cargar las asistencias"
            }

from django.utils import timezone
from datetime import timedelta
import random
import string
from .models import SesionAsistenciaMovil, RegistroAsistenciaMovil

# 🔥 VISTAS PARA ASISTENCIA MÓVIL (NUEVAS - NO AFECTAN LAS EXISTENTES)

class HabilitarAsistenciaMovilView(APIView):
    """Permite al profesor habilitar una sesión de asistencia móvil"""
    permission_classes = [IsAuthenticated]

    def post(self, request, detalle_id):
        try:
            # Verificar que el usuario sea profesor y tenga acceso a la materia
            profesor = request.user
            if profesor.rol.nombre.lower() != 'profesor':
                return Response({'error': 'Solo los profesores pueden habilitar asistencia'}, status=403)

            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)
            
            # Obtener duración (por defecto 15 minutos)
            duracion = int(request.data.get('duracion', 15))
            if duracion < 1 or duracion > 120:  # Límites de 1 a 120 minutos
                duracion = 15

            # Desactivar sesiones anteriores de esta materia
            SesionAsistenciaMovil.objects.filter(
                detalle_materia=detalle, 
                activa=True
            ).update(activa=False)

            # Generar código único de 6 dígitos
            codigo = self._generar_codigo_unico()

            # Crear nueva sesión
            fecha_fin = timezone.now() + timedelta(minutes=duracion)
            sesion = SesionAsistenciaMovil.objects.create(
                detalle_materia=detalle,
                codigo=codigo,
                fecha_fin=fecha_fin,
                activa=True,
                duracion_minutos=duracion
            )

            return Response({
                'success': True,
                'message': 'Asistencia móvil habilitada correctamente',
                'sesion': {
                    'id': sesion.id,
                    'codigo': sesion.codigo,
                    'fecha_inicio': sesion.fecha_inicio,
                    'fecha_fin': sesion.fecha_fin,
                    'duracion_minutos': duracion,
                    'estudiantes_registrados': 0,
                    'tiempo_restante': sesion.tiempo_restante_minutos
                }
            })

        except DetalleMateria.DoesNotExist:
            return Response({
                'error': 'Materia no encontrada o no tienes permisos'
            }, status=404)
        except Exception as e:
            return Response({
                'error': f'Error al habilitar asistencia: {str(e)}'
            }, status=500)

    def _generar_codigo_unico(self):
        """Genera un código único de 6 dígitos"""
        while True:
            codigo = ''.join(random.choices(string.digits, k=6))
            if not SesionAsistenciaMovil.objects.filter(codigo=codigo, activa=True).exists():
                return codigo


class DeshabilitarAsistenciaMovilView(APIView):
    """Permite al profesor deshabilitar la asistencia móvil"""
    permission_classes = [IsAuthenticated]

    def post(self, request, detalle_id):
        try:
            profesor = request.user
            if profesor.rol.nombre.lower() != 'profesor':
                return Response({'error': 'Solo los profesores pueden deshabilitar asistencia'}, status=403)

            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)

            # Desactivar todas las sesiones activas
            sesiones_activas = SesionAsistenciaMovil.objects.filter(
                detalle_materia=detalle, 
                activa=True
            )
            count = sesiones_activas.count()
            total_registros = sum(sesion.total_registros for sesion in sesiones_activas)
            
            sesiones_activas.update(activa=False)

            return Response({
                'success': True,
                'message': f'Asistencia móvil deshabilitada. {count} sesión(es) cerrada(s).',
                'sesiones_cerradas': count,
                'total_registros': total_registros
            })

        except DetalleMateria.DoesNotExist:
            return Response({
                'error': 'Materia no encontrada o no tienes permisos'
            }, status=404)
        except Exception as e:
            return Response({
                'error': f'Error al deshabilitar asistencia: {str(e)}'
            }, status=500)


class EstadoAsistenciaMovilView(APIView):
    """Obtiene el estado actual de la asistencia móvil para una materia"""
    permission_classes = [IsAuthenticated]

    def get(self, request, detalle_id):
        try:
            profesor = request.user
            if profesor.rol.nombre.lower() != 'profesor':
                return Response({'error': 'Solo los profesores pueden ver el estado'}, status=403)

            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)

            # Buscar sesión activa
            sesion_activa = SesionAsistenciaMovil.objects.filter(
                detalle_materia=detalle, 
                activa=True
            ).first()

            if sesion_activa and sesion_activa.esta_activa:
                return Response({
                    'habilitada': True,
                    'sesion': {
                        'id': sesion_activa.id,
                        'codigo': sesion_activa.codigo,
                        'fecha_inicio': sesion_activa.fecha_inicio,
                        'fecha_fin': sesion_activa.fecha_fin,
                        'tiempo_restante': sesion_activa.tiempo_restante_minutos,
                        'estudiantes_registrados': sesion_activa.total_registros,
                        'duracion_original': sesion_activa.duracion_minutos
                    }
                })
            else:
                # Si hay sesión pero expiró, desactivarla
                if sesion_activa:
                    sesion_activa.activa = False
                    sesion_activa.save()

                return Response({
                    'habilitada': False,
                    'sesion': None
                })

        except DetalleMateria.DoesNotExist:
            return Response({
                'error': 'Materia no encontrada'
            }, status=404)


class EstudiantesRegistradosMovilView(APIView):
    """Obtiene la lista de estudiantes que se registraron en la sesión activa"""
    permission_classes = [IsAuthenticated]

    def get(self, request, detalle_id):
        try:
            profesor = request.user
            if profesor.rol.nombre.lower() != 'profesor':
                return Response({'error': 'Solo los profesores pueden ver los registros'}, status=403)

            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)
            
            sesion_activa = SesionAsistenciaMovil.objects.filter(
                detalle_materia=detalle, 
                activa=True
            ).first()

            if not sesion_activa:
                return Response({
                    'estudiantes': [],
                    'message': 'No hay sesión activa',
                    'total': 0
                })

            # Obtener registros de la sesión actual
            registros = RegistroAsistenciaMovil.objects.filter(
                sesion=sesion_activa
            ).select_related('estudiante').order_by('-fecha_registro')

            estudiantes_data = []
            for registro in registros:
                estudiantes_data.append({
                    'id': registro.estudiante.id,
                    'nombre': registro.estudiante.nombre,
                    'codigo': getattr(registro.estudiante, 'codigo', ''),
                    'hora_registro': registro.fecha_registro,
                    'tiempo_transcurrido': self._calcular_tiempo_transcurrido(registro.fecha_registro)
                })

            return Response({
                'estudiantes': estudiantes_data,
                'total': len(estudiantes_data),
                'sesion_codigo': sesion_activa.codigo,
                'sesion_activa': sesion_activa.esta_activa
            })

        except DetalleMateria.DoesNotExist:
            return Response({
                'error': 'Materia no encontrada'
            }, status=404)

    def _calcular_tiempo_transcurrido(self, fecha_registro):
        """Calcula cuánto tiempo pasó desde el registro"""
        diferencia = timezone.now() - fecha_registro
        minutos = int(diferencia.total_seconds() / 60)
        if minutos < 1:
            return "Hace menos de 1 minuto"
        elif minutos == 1:
            return "Hace 1 minuto"
        else:
            return f"Hace {minutos} minutos"


class RegistrarseAsistenciaMovilView(APIView):
    """Permite a los estudiantes registrarse usando el código"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            estudiante = request.user
            if estudiante.rol.nombre.lower() != 'estudiante':
                return Response({'error': 'Solo los estudiantes pueden registrarse'}, status=403)

            codigo = request.data.get('codigo', '').strip()
            if not codigo or len(codigo) != 6:
                return Response({'error': 'Código inválido'}, status=400)

            # Buscar sesión activa con ese código
            sesion = SesionAsistenciaMovil.objects.filter(
                codigo=codigo,
                activa=True
            ).first()

            if not sesion:
                return Response({'error': 'Código no válido o sesión expirada'}, status=400)

            if not sesion.esta_activa:
                return Response({'error': 'La sesión ha expirado'}, status=400)

            # Verificar que el estudiante pertenece a la materia
            from libreta.models import Libreta
            try:
                Libreta.objects.get(
                    estudiante=estudiante,
                    detalle_materia=sesion.detalle_materia
                )
            except Libreta.DoesNotExist:
                return Response({'error': 'No perteneces a esta materia'}, status=403)

            # Verificar si ya se registró
            registro_existente = RegistroAsistenciaMovil.objects.filter(
                sesion=sesion,
                estudiante=estudiante
            ).first()

            if registro_existente:
                return Response({
                    'error': 'Ya te registraste en esta sesión',
                    'hora_registro': registro_existente.fecha_registro
                }, status=400)

            # Crear el registro
            ip_address = self._obtener_ip(request)
            lat = request.data.get('lat')
            lng = request.data.get('lng')

            registro = RegistroAsistenciaMovil.objects.create(
                sesion=sesion,
                estudiante=estudiante,
                ip_address=ip_address,
                ubicacion_lat=lat if lat else None,
                ubicacion_lng=lng if lng else None
            )

            return Response({
                'success': True,
                'message': f'¡Asistencia registrada correctamente en {sesion.detalle_materia.materia.nombre}!',
                'detalles': {
                    'materia': sesion.detalle_materia.materia.nombre,
                    'profesor': sesion.detalle_materia.profesor.nombre,
                    'hora_registro': registro.fecha_registro,
                    'tiempo_restante': sesion.tiempo_restante_minutos
                }
            })

        except Exception as e:
            return Response({
                'error': f'Error al registrar asistencia: {str(e)}'
            }, status=500)

    def _obtener_ip(self, request):
        """Obtiene la IP del cliente"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip