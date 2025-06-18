from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from rest_framework import viewsets
from materia.models import DetalleMateria
from .models import Dimension, Actividad, DetalleActividad,EntregaTarea
from libreta.models import Libreta
from .serializers import DimensionSerializer, ActividadSerializer, DetalleActividadSerializer, EntregaTareaSerializer

class DimensionViewSet(viewsets.ModelViewSet):
    queryset = Dimension.objects.all()
    serializer_class = DimensionSerializer

class ActividadViewSet(viewsets.ModelViewSet):
    queryset = Actividad.objects.all()
    serializer_class = ActividadSerializer

class DetalleActividadViewSet(viewsets.ModelViewSet):
    queryset = DetalleActividad.objects.all()
    serializer_class = DetalleActividadSerializer

class CrearActividadConDetalleView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, detalle_id):
        profesor = request.user

        try:
            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)
        except DetalleMateria.DoesNotExist:
            return Response({'error': 'No autorizado para esta materia'}, status=403)

        data = request.data.copy()
        dimension_id = data.get('dimension')

        if not dimension_id or not Dimension.objects.filter(id=dimension_id).exists():
            return Response({'error': 'Dimensión inválida'}, status=400)

        # Crear la actividad
        actividad_serializer = ActividadSerializer(data=data)
        if actividad_serializer.is_valid():
            actividad = actividad_serializer.save()

            # Crear la asociación con DetalleMateria
            DetalleActividad.objects.create(
                actividad=actividad,
                detalle_materia=detalle
            )

            return Response(actividad_serializer.data, status=status.HTTP_201_CREATED)

        return Response(actividad_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class ListarActividadesPorMateriaView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, detalle_id):
        profesor = request.user

        # Validar que el profesor sea dueño de la materia
        try:
            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)
        except DetalleMateria.DoesNotExist:
            return Response({'error': 'No autorizado para esta materia'}, status=403)

        # Obtener todas las actividades asociadas a la materia a través de DetalleActividad
        detalle_actividades = DetalleActividad.objects.filter(detalle_materia=detalle).select_related('actividad')

        actividades = [da.actividad for da in detalle_actividades]

        serializer = ActividadSerializer(actividades, many=True)
        return Response(serializer.data)

class RegistrarEntregasActividadView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, actividad_id):
        profesor = request.user

        try:
            actividad = Actividad.objects.get(id=actividad_id)
        except Actividad.DoesNotExist:
            return Response({'error': 'Actividad no encontrada'}, status=404)

        # Validar que el profesor tenga acceso a esa actividad
        if not actividad.detalles_actividad.filter(detalle_materia__profesor=profesor).exists():
            return Response({'error': 'No autorizado para esta actividad'}, status=403)

        entregas = request.data
        if not isinstance(entregas, list):
            return Response({'error': 'Se requiere una lista de entregas'}, status=400)

        resultados = []
        errores = []

        for entrega in entregas:
            usuario_id = entrega.get('usuario_id')
            entregado = entrega.get('entregado')
            calificacion = entrega.get('calificacion')

            if usuario_id is None or entregado is None:
                errores.append({'usuario_id': usuario_id, 'error': 'Faltan datos'})
                continue

            obj, creado = EntregaTarea.objects.update_or_create(
                actividad=actividad,
                usuario_id=usuario_id,
                defaults={
                    'entregado': entregado,
                    'calificacion': calificacion if entregado else None
                }
            )
            resultados.append({
                'usuario_id': usuario_id,
                'entregado': entregado,
                'calificacion': obj.calificacion,
                'estado': 'creado' if creado else 'actualizado'
            })

        return Response({'procesados': resultados, 'errores': errores})
    
class ListarEntregasPorActividadView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, detalle_id, actividad_id):
        profesor = request.user

        try:
            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)
            actividad = Actividad.objects.get(id=actividad_id)
        except (DetalleMateria.DoesNotExist, Actividad.DoesNotExist):
            return Response({'error': 'No autorizado o no encontrado'}, status=403)

        libretas = Libreta.objects.filter(detalle_materia=detalle).select_related('estudiante')

        resultado = []

        for libreta in libretas:
            estudiante = libreta.estudiante
            entrega = EntregaTarea.objects.filter(actividad=actividad, usuario=estudiante).first()

            resultado.append({
                'usuario': estudiante.id,
                'nombreEstudiante': estudiante.nombre,
                'entregado': entrega.entregado if entrega else False,
                'calificacion': entrega.calificacion if entrega else None
            })

        return Response(resultado)
    
class ReporteEntregasView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, detalle_id):
        profesor = request.user

        try:
            detalle = DetalleMateria.objects.get(id=detalle_id, profesor=profesor)
        except DetalleMateria.DoesNotExist:
            return Response({'error': 'No autorizado'}, status=403)

        actividades = Actividad.objects.filter(detalles_actividad__detalle_materia=detalle).distinct()
        libretas = Libreta.objects.filter(detalle_materia=detalle).select_related('estudiante')

        resultado = []

        for libreta in libretas:
            estudiante = libreta.estudiante

            entregas_por_actividad = []
            for actividad in actividades:
                entrega = EntregaTarea.objects.filter(actividad=actividad, usuario=estudiante).first()

                entregas_por_actividad.append({
                    "actividad": actividad.nombre,
                    "entregado": entrega.entregado if entrega else False,
                    "fecha_entrega": entrega.fecha_entrega.isoformat() if entrega and entrega.fecha_entrega else None,
                    "calificacion": entrega.calificacion if entrega else None
                })

            resultado.append({
                "id": estudiante.id,
                "nombre": estudiante.nombre,
                "entregas": entregas_por_actividad
            })

        actividades_nombres = [a.nombre for a in actividades]

        return Response({
            "estudiantes": resultado,
            "actividades": actividades_nombres
        })