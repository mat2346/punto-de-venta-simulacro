from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from .ml_models import predecir_riesgo_y_nota
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

@swagger_auto_schema(
    method='post',
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        required=[],
        properties={
            'ser': openapi.Schema(type=openapi.TYPE_NUMBER, description='Nota en dimensión ser (0-100)'),
            'saber': openapi.Schema(type=openapi.TYPE_NUMBER, description='Nota en dimensión saber (0-100)'),
            'hacer': openapi.Schema(type=openapi.TYPE_NUMBER, description='Nota en dimensión hacer (0-100)'),
            'decidir': openapi.Schema(type=openapi.TYPE_NUMBER, description='Nota en dimensión decidir (0-100)'),
        }
    ),
    responses={
        200: openapi.Response(
            description="Predicción exitosa",
            schema=openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'nota_final_estimada': openapi.Schema(type=openapi.TYPE_NUMBER, description='Nota final estimada'),
                    'estado_predicho': openapi.Schema(type=openapi.TYPE_STRING, description='Aprobado o Reprobado'),
                    'riesgo_reprobacion': openapi.Schema(type=openapi.TYPE_BOOLEAN, description='Indica si hay riesgo de reprobar'),
                    'notas_utilizadas': openapi.Schema(type=openapi.TYPE_OBJECT, description='Notas utilizadas para la predicción')
                }
            )
        ),
        400: openapi.Response(description="Parámetros inválidos"),
        500: openapi.Response(description="Error en el servidor")
    },
    operation_description="Predecir la nota final y el estado (aprobado/reprobado) basado en las notas parciales por dimensión"
)
@api_view(['POST'])
# @permission_classes([IsAuthenticated])
def prediccion_api(request):
    """
    API para predecir la nota final basada en notas parciales
    
    Parámetros:
    - ser (opcional): Nota en la dimensión ser (0-100)
    - saber (opcional): Nota en la dimensión saber (0-100)
    - hacer (opcional): Nota en la dimensión hacer (0-100)
    - decidir (opcional): Nota en la dimensión decidir (0-100)
    
    Se pueden enviar todas o algunas de las dimensiones.
    """
    try:
        # Extraer notas de la solicitud
        notas_parciales = {}
        
        # Validar y convertir cada dimensión
        for dimension in ['ser', 'saber', 'hacer', 'decidir']:
            if dimension in request.data:
                try:
                    valor = float(request.data[dimension])
                    if 0 <= valor <= 100:  # Validar rango
                        notas_parciales[dimension] = valor
                    else:
                        return Response(
                            {"error": f"La nota de {dimension} debe estar entre 0 y 100"},
                            status=status.HTTP_400_BAD_REQUEST
                        )
                except (ValueError, TypeError):
                    return Response(
                        {"error": f"La nota de {dimension} debe ser un número válido"},
                        status=status.HTTP_400_BAD_REQUEST
                    )
        
        # Verificar que hay al menos una dimensión
        if not notas_parciales:
            return Response(
                {"error": "Debe proporcionar al menos una nota parcial"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Realizar predicción
        nota_predicha, estado = predecir_riesgo_y_nota(notas_parciales)
        
        if nota_predicha is None:
            return Response(
                {"error": "Error al cargar los modelos de predicción"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
        # Devolver resultado
        return Response({
            "nota_final_estimada": nota_predicha,
            "estado_predicho": estado,
            "riesgo_reprobacion": estado == "Reprobado",
            "notas_utilizadas": notas_parciales
        })
        
    except Exception as e:
        return Response(
            {"error": f"Error en la predicción: {str(e)}"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

# # También podemos crear una vista basada en clase si prefieres
# class PrediccionNotaView(APIView):
#     permission_classes = [IsAuthenticated]
    
#     def post(self, request):
#         """
#         Endpoint para predecir la nota final basada en notas parciales
#         """
#         try:
#             # Extraer notas de la solicitud
#             notas_parciales = {}
            
#             # Validar y convertir cada dimensión
#             for dimension in ['ser', 'saber', 'hacer', 'decidir']:
#                 if dimension in request.data:
#                     try:
#                         valor = float(request.data[dimension])
#                         if 0 <= valor <= 100:  # Validar rango
#                             notas_parciales[dimension] = valor
#                         else:
#                             return Response(
#                                 {"error": f"La nota de {dimension} debe estar entre 0 y 100"},
#                                 status=status.HTTP_400_BAD_REQUEST
#                             )
#                     except (ValueError, TypeError):
#                         return Response(
#                             {"error": f"La nota de {dimension} debe ser un número válido"},
#                             status=status.HTTP_400_BAD_REQUEST
#                         )
            
#             # Verificar que hay al menos una dimensión
#             if not notas_parciales:
#                 return Response(
#                     {"error": "Debe proporcionar al menos una nota parcial"},
#                     status=status.HTTP_400_BAD_REQUEST
#                 )
            
#             # Realizar predicción
#             nota_predicha, estado = predecir_riesgo_y_nota(notas_parciales)
            
#             if nota_predicha is None:
#                 return Response(
#                     {"error": "Error al cargar los modelos de predicción"},
#                     status=status.HTTP_500_INTERNAL_SERVER_ERROR
#                 )
            
#             # Devolver resultado
#             return Response({
#                 "nota_final_estimada": nota_predicha,
#                 "estado_predicho": estado,
#                 "riesgo_reprobacion": estado == "Reprobado",
#                 "notas_utilizadas": notas_parciales,
#                 "mensaje": f"Con estas notas parciales, se estima una nota final de {nota_predicha} ({estado})"
#             })
            
#         except Exception as e:
#             return Response(
#                 {"error": f"Error en la predicción: {str(e)}"},
#                 status=status.HTTP_500_INTERNAL_SERVER_ERROR
#             )

# class PrediccionAutomaticaView(APIView):
#     permission_classes = [IsAuthenticated]
    
#     def get(self, request, detalle_id):
#         """Realizar predicción automática basada en notas existentes en el sistema"""
#         try:
#             # Verificar que el usuario tenga acceso a la materia
#             if request.user.rol.nombre.lower() != 'estudiante':
#                 return Response({"error": "Solo estudiantes pueden acceder a esta función"}, 
#                              status=status.HTTP_403_FORBIDDEN)
            
#             estudiante = request.user
#             detalle = DetalleMateria.objects.get(id=detalle_id)
            
#             # Verificar si el estudiante está matriculado en esta materia
#             if not estudiante.libretas.filter(detalle_materia=detalle).exists():
#                 return Response({"error": "No tienes acceso a esta materia"}, 
#                              status=status.HTTP_403_FORBIDDEN)
            
#             # Obtener actividades de la materia agrupadas por dimensión
#             actividades = Actividad.objects.filter(
#                 detalles_actividad__detalle_materia=detalle
#             ).distinct()
            
#             # Calcular promedios por dimensión
#             dimensiones = {'ser': [], 'saber': [], 'hacer': [], 'decidir': []}
            
#             for actividad in actividades:
#                 dimension = actividad.dimension.nombre.lower()
#                 if dimension not in dimensiones:
#                     continue
                
#                 # Buscar entregas calificadas
#                 entrega = EntregaTarea.objects.filter(
#                     actividad=actividad,
#                     usuario=estudiante,
#                     entregado=True,
#                     calificacion__isnull=False
#                 ).first()
                
#                 if entrega and entrega.calificacion:
#                     dimensiones[dimension].append(float(entrega.calificacion))
            
#             # Calcular promedios de cada dimensión
#             notas_parciales = {}
#             for dimension, notas in dimensiones.items():
#                 if notas:
#                     notas_parciales[dimension] = sum(notas) / len(notas)
            
#             # Realizar predicción
#             nota_predicha, estado = predecir_riesgo_y_nota(notas_parciales)
            
#             if nota_predicha is None:
#                 return Response({"error": "Error al cargar modelos de predicción"}, 
#                               status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
#             # Guardar predicción (opcional)
#             prediccion = PrediccionNota.objects.create(
#                 estudiante=estudiante,
#                 detalle_materia=detalle,
#                 ser=notas_parciales.get('ser'),
#                 saber=notas_parciales.get('saber'),
#                 hacer=notas_parciales.get('hacer'),
#                 decidir=notas_parciales.get('decidir'),
#                 nota_predicha=nota_predicha,
#                 estado_predicho=estado
#             )
            
#             return Response({
#                 "materia": detalle.materia.nombre,
#                 "nota_predicha": nota_predicha,
#                 "estado": estado,
#                 "riesgo_reprobar": estado == "Reprobado",
#                 "notas_actuales": notas_parciales
#             })
            
#         except DetalleMateria.DoesNotExist:
#             return Response({"error": "Materia no encontrada"}, status=status.HTTP_404_NOT_FOUND)
#         except Exception as e:
#             return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# class PrediccionLibretaView(APIView):
#     permission_classes = [IsAuthenticated]
    
#     def get(self, request, libreta_id):
#         """Realizar predicción basada en una libreta específica"""
#         try:
#             # Verificar que el usuario tenga acceso a la libreta
#             estudiante = request.user
            
#             if request.user.rol.nombre.lower() != 'estudiante':
#                 return Response({"error": "Solo estudiantes pueden acceder a esta función"}, 
#                              status=status.HTTP_403_FORBIDDEN)
            
#             # Obtener la libreta y verificar acceso
#             try:
#                 libreta = Libreta.objects.get(id=libreta_id, estudiante=estudiante)
#             except Libreta.DoesNotExist:
#                 return Response({"error": "Libreta no encontrada o no tienes acceso"}, 
#                               status=status.HTTP_404_NOT_FOUND)
            
#             detalle = libreta.detalle_materia
            
#             # Obtener actividades de la materia agrupadas por dimensión
#             actividades = Actividad.objects.filter(
#                 detalles_actividad__detalle_materia=detalle
#             ).distinct()
            
#             # Calcular promedios por dimensión
#             dimensiones = {'ser': [], 'saber': [], 'hacer': [], 'decidir': []}
            
#             for actividad in actividades:
#                 # Verificar que la actividad tenga dimensión
#                 if not hasattr(actividad, 'dimension') or not actividad.dimension:
#                     continue
                    
#                 dimension = actividad.dimension.nombre.lower()
#                 if dimension not in dimensiones:
#                     continue
                
#                 # Buscar entregas calificadas
#                 entrega = EntregaTarea.objects.filter(
#                     actividad=actividad,
#                     usuario=estudiante,
#                     entregado=True,
#                     calificacion__isnull=False
#                 ).first()
                
#                 if entrega and entrega.calificacion:
#                     dimensiones[dimension].append(float(entrega.calificacion))
            
#             # Calcular promedios de cada dimensión
#             notas_parciales = {}
#             for dimension, notas in dimensiones.items():
#                 if notas:
#                     notas_parciales[dimension] = sum(notas) / len(notas)
            
#             # Realizar predicción
#             nota_predicha, estado = predecir_riesgo_y_nota(notas_parciales)
            
#             if nota_predicha is None:
#                 return Response({"error": "Error al cargar modelos de predicción"}, 
#                               status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
#             # Guardar predicción
#             prediccion = PrediccionNota.objects.create(
#                 estudiante=estudiante,
#                 libreta=libreta,
#                 detalle_materia=detalle,
#                 ser=notas_parciales.get('ser'),
#                 saber=notas_parciales.get('saber'),
#                 hacer=notas_parciales.get('hacer'),
#                 decidir=notas_parciales.get('decidir'),
#                 nota_predicha=nota_predicha,
#                 estado_predicho=estado
#             )
            
#             # Actualizar nota en la libreta (opcional)
#             # Si quieres guardar la predicción como nota real, descomenta:
#             # libreta.nota = nota_predicha
#             # libreta.save()
            
#             return Response({
#                 "materia": detalle.materia.nombre,
#                 "estudiante": estudiante.nombre,
#                 "nota_predicha": nota_predicha,
#                 "estado": estado,
#                 "riesgo_reprobar": estado == "Reprobado",
#                 "notas_actuales": notas_parciales,
#                 "gestion": libreta.gestion.nombre,
#                 "curso": f"{detalle.curso.nombre} {detalle.curso.paralelo.nombre}" if detalle.curso else "No definido"
#             })
            
#         except Exception as e:
#             return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
