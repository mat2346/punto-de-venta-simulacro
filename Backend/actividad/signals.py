from django.db.models.signals import post_save
from django.dispatch import receiver
from django.db.models import Avg, Q
from decimal import Decimal
import requests
import json
import logging
from typing import Dict, Optional, Tuple

from .models import EntregaTarea, DetalleActividad
from actividad.models import Actividad, Dimension
from materia.models import DetalleMateria, Asistencia
from libreta.models import Libreta
from usuarios.models import Usuario

# Configurar logging
logger = logging.getLogger(__name__)

@receiver(post_save, sender=EntregaTarea)
def procesar_calificacion_y_predecir(sender, instance: EntregaTarea, created: bool, **kwargs):
    """
    Signal que se ejecuta cada vez que se guarda una EntregaTarea.
    Si tiene calificación no nula, calcula promedios por dimensión,
    hace predicción de ML y envía notificaciones si el rendimiento es bajo.
    """
    # Solo procesar si tiene calificación
    if instance.calificacion is None:
        return
    
    try:
        # 1. Obtener datos básicos
        estudiante = instance.usuario
        actividad = instance.actividad
        
        # Obtener materia y gestión a través de las relaciones
        detalle_actividad = DetalleActividad.objects.filter(actividad=actividad).first()
        if not detalle_actividad:
            logger.warning(f"No se encontró DetalleActividad para actividad {actividad.id}")
            return
            
        detalle_materia = detalle_actividad.detalle_materia
        
        # Obtener gestión a través de la libreta del estudiante
        libreta = Libreta.objects.filter(
            estudiante=estudiante,
            detalle_materia=detalle_materia
        ).first()
        
        if not libreta:
            logger.warning(f"No se encontró libreta para estudiante {estudiante.id} y materia {detalle_materia.id}")
            return
            
        gestion = libreta.gestion
        
        logger.info(f"Procesando calificación para estudiante {estudiante.nombre} en {detalle_materia.materia.nombre}")
        
        # 2. Calcular promedios por dimensión
        promedios_dimensiones = calcular_promedios_por_dimension(
            estudiante, detalle_materia, gestion
        )
        
        if not promedios_dimensiones:
            logger.warning("No se pudieron calcular promedios por dimensión")
            return
            
        logger.info(f"Promedios calculados: {promedios_dimensiones}")
        
        # 3. Hacer predicción con ML
        prediccion = realizar_prediccion_ml(promedios_dimensiones)
        
        if prediccion is None:
            logger.error("No se pudo obtener predicción del modelo ML")
            return
            
        nota_predicha = prediccion.get('nota_final_estimada', 0)
        estado_predicho = prediccion.get('estado_predicho', 'Desconocido')
        
        logger.info(f"Predicción obtenida: {nota_predicha} ({estado_predicho})")
        
        # 4. Enviar notificaciones si el rendimiento es bajo
        if nota_predicha < 51:
            enviar_notificaciones_rendimiento_bajo(
                estudiante, detalle_materia.materia.nombre, nota_predicha, estado_predicho
            )
            
    except Exception as e:
        logger.error(f"Error en signal de calificación: {str(e)}")
        import traceback
        traceback.print_exc()


def calcular_promedios_por_dimension(estudiante: Usuario, detalle_materia: DetalleMateria, gestion) -> Dict[str, float]:
    """
    Calcula los promedios por dimensión para un estudiante específico.
    """
    promedios = {}
    
    try:
        # Obtener todas las dimensiones disponibles
        dimensiones = Dimension.objects.all()
        
        for dimension in dimensiones:
            dimension_nombre = dimension.nombre.lower()
            
            # Obtener actividades de esta dimensión para esta materia
            actividades_dimension = Actividad.objects.filter(
                dimension=dimension,
                detalles_actividad__detalle_materia=detalle_materia
            ).distinct()
            
            if not actividades_dimension.exists():
                continue
                
            # Obtener entregas calificadas para estas actividades
            entregas_calificadas = EntregaTarea.objects.filter(
                actividad__in=actividades_dimension,
                usuario=estudiante,
                entregado=True,
                calificacion__isnull=False
            )
            
            if not entregas_calificadas.exists():
                continue
                
            # Calcular promedio base de las actividades
            calificaciones = [float(entrega.calificacion) for entrega in entregas_calificadas]
            promedio_actividades = sum(calificaciones) / len(calificaciones)
            cantidad_actividades = len(calificaciones)
            
            # Para la dimensión "ser", incluir porcentaje de asistencia
            if dimension_nombre == 'ser':
                porcentaje_asistencia = calcular_porcentaje_asistencia(
                    estudiante, detalle_materia, gestion
                )
                
                # Fórmula: (promedio acumulado + porcentaje asistencia) / (cantidad actividades + 1)
                promedio_final = (promedio_actividades * cantidad_actividades + porcentaje_asistencia) / (cantidad_actividades + 1)
                
                logger.info(f"Dimensión SER: promedio actividades={promedio_actividades:.2f}, "
                           f"asistencia={porcentaje_asistencia:.2f}, promedio final={promedio_final:.2f}")
            else:
                promedio_final = promedio_actividades
                
            promedios[dimension_nombre] = round(promedio_final, 2)
            
    except Exception as e:
        logger.error(f"Error calculando promedios por dimensión: {str(e)}")
        
    return promedios


def calcular_porcentaje_asistencia(estudiante: Usuario, detalle_materia: DetalleMateria, gestion) -> float:
    """
    Calcula el porcentaje de asistencia para un estudiante en una materia y gestión específica.
    """
    try:
        # Contar asistencias totales y presentes
        total_asistencias = Asistencia.objects.filter(
            estudiante=estudiante,
            detalle_materia=detalle_materia
        ).count()
        
        asistencias_presentes = Asistencia.objects.filter(
            estudiante=estudiante,
            detalle_materia=detalle_materia,
            presente=True
        ).count()
        
        if total_asistencias == 0:
            return 100.0  # Si no hay asistencias registradas, asumir 100%
            
        porcentaje = (asistencias_presentes / total_asistencias) * 100
        return round(porcentaje, 2)
        
    except Exception as e:
        logger.error(f"Error calculando porcentaje de asistencia: {str(e)}")
        return 100.0  # Valor por defecto en caso de error


def realizar_prediccion_ml(promedios_dimensiones: Dict[str, float]) -> Optional[Dict]:
    """
    Envía los promedios al modelo de ML y obtiene la predicción.
    """
    try:
        # URL del endpoint de predicción (ajustar según tu configuración)
        # Asumiendo que tienes el endpoint que ya definiste en views.py
        url = "http://127.0.0.1:8000/api/predecir/"  # URL corregida
        
        # Preparar datos para enviar
        data = {}
        for dimension, promedio in promedios_dimensiones.items():
            data[dimension] = promedio
            
        # Hacer petición POST
        response = requests.post(
            url,
            json=data,
            headers={'Content-Type': 'application/json'},
            timeout=10
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            logger.error(f"Error en predicción ML: {response.status_code} - {response.text}")
            return None
            
    except requests.RequestException as e:
        logger.error(f"Error de conexión con ML: {str(e)}")
        return None
    except Exception as e:
        logger.error(f"Error general en predicción ML: {str(e)}")
        return None


def enviar_notificaciones_rendimiento_bajo(estudiante: Usuario, materia_nombre: str, nota_predicha: float, estado_predicho: str):
    """
    Envía notificaciones push al estudiante y su tutor cuando el rendimiento es bajo.
    """
    try:
        # Importar aquí para evitar dependencias circulares
        from notificaciones.firebase import enviar_notificacion
        
        # Mensaje de la notificación
        titulo = "⚠️ Alerta de Rendimiento"
        mensaje = f"El rendimiento en {materia_nombre} requiere atención. Nota estimada: {nota_predicha:.1f}"
        
        datos_extra = {
            "tipo": "rendimiento_bajo",
            "materia": materia_nombre,
            "nota_predicha": str(nota_predicha),  # Convertir a string
            "estado": estado_predicho,
            "estudiante_id": str(estudiante.id)   # Convertir a string
        }
        
        # Enviar notificación al estudiante
        if estudiante.fcm_token:
            try:
                resultado_estudiante = enviar_notificacion(
                    estudiante.fcm_token,
                    titulo,
                    mensaje,
                    datos_extra
                )
                logger.info(f"Notificación enviada al estudiante {estudiante.nombre}: {resultado_estudiante}")
            except Exception as e:
                logger.error(f"Error enviando notificación al estudiante: {str(e)}")
        
        # Enviar notificación al tutor si existe
        if estudiante.tutor and estudiante.tutor.fcm_token:
            mensaje_tutor = f"El rendimiento de {estudiante.nombre} en {materia_nombre} requiere atención. Nota estimada: {nota_predicha:.1f}"
            
            try:
                resultado_tutor = enviar_notificacion(
                    estudiante.tutor.fcm_token,
                    titulo,
                    mensaje_tutor,
                    datos_extra
                )
                logger.info(f"Notificación enviada al tutor {estudiante.tutor.nombre}: {resultado_tutor}")
            except Exception as e:
                logger.error(f"Error enviando notificación al tutor: {str(e)}")
                
        logger.info(f"Proceso de notificaciones completado para {estudiante.nombre}")
        
    except ImportError:
        logger.warning("Módulo de notificaciones no disponible")
    except Exception as e:
        logger.error(f"Error general enviando notificaciones: {str(e)}")


# Función auxiliar para testing manual
def test_calculo_promedios(estudiante_id: int, detalle_materia_id: int):
    """
    Función de prueba para calcular promedios manualmente.
    Útil para debugging.
    """
    try:
        estudiante = Usuario.objects.get(id=estudiante_id)
        detalle_materia = DetalleMateria.objects.get(id=detalle_materia_id)
        
        libreta = Libreta.objects.filter(
            estudiante=estudiante,
            detalle_materia=detalle_materia
        ).first()
        
        if not libreta:
            print("No se encontró libreta")
            return
            
        promedios = calcular_promedios_por_dimension(estudiante, detalle_materia, libreta.gestion)
        print(f"Promedios calculados: {promedios}")
        
        if promedios:
            prediccion = realizar_prediccion_ml(promedios)
            print(f"Predicción: {prediccion}")
            
    except Exception as e:
        print(f"Error en test: {str(e)}")
        import traceback
        traceback.print_exc()