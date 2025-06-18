from rest_framework.routers import DefaultRouter
from django.urls import path
from .views import (
    NivelViewSet, MateriaViewSet, 
    DetalleMateriaViewSet, AsistenciaViewSet,
    MateriasDelProfesorView, MateriasDelAlumnoView,
    EstudiantesDeMateriaView,
    RegistrarAsistenciaDesdeLibreta,
    ObtenerAsistenciaPorFechaView,
    ReporteAsistenciaGestionView,
    MateriaDetalleAlumnoView,
    # 🔥 NUEVAS VISTAS PARA ASISTENCIA MÓVIL
    HabilitarAsistenciaMovilView,
    DeshabilitarAsistenciaMovilView,
    EstadoAsistenciaMovilView,
    RegistrarseAsistenciaMovilView,
    EstudiantesRegistradosMovilView,
)

router = DefaultRouter()
router.register(r'niveles', NivelViewSet)
router.register(r'materias', MateriaViewSet)
router.register(r'detalles-materia', DetalleMateriaViewSet)
router.register(r'asistencias', AsistenciaViewSet)

urlpatterns = router.urls

# 🔥 URLS ORIGINALES (NO TOCAR)
urlpatterns += [
    path('profesor/materias/', MateriasDelProfesorView.as_view(), name='materias-profesor'),
    path('alumno/materias/', MateriasDelAlumnoView.as_view(), name='materias-alumno'),
    path('profesor/materia/<int:detalle_id>/estudiantes/', EstudiantesDeMateriaView.as_view(), name='profesor-materia-estudiantes'),
    path('profesor/materia/<int:detalle_id>/registrar-asistencia/', RegistrarAsistenciaDesdeLibreta.as_view()),
    path('profesor/materia/<int:detalle_id>/asistencia-por-fecha/', ObtenerAsistenciaPorFechaView.as_view()),
    path('profesor/materia/<int:detalle_id>/reporte-asistencia/', ReporteAsistenciaGestionView.as_view()),
    path('alumno/materia/<int:detalle_id>/detalle/', MateriaDetalleAlumnoView.as_view(), name='detalle-materia-alumno'),
]

# 🔥 NUEVAS URLS PARA ASISTENCIA MÓVIL (SEPARADAS)
urlpatterns += [
    # Para profesores
    path('profesor/materia/<int:detalle_id>/asistencia-movil/habilitar/', HabilitarAsistenciaMovilView.as_view(), name='habilitar-asistencia-movil'),
    path('profesor/materia/<int:detalle_id>/asistencia-movil/deshabilitar/', DeshabilitarAsistenciaMovilView.as_view(), name='deshabilitar-asistencia-movil'),
    path('profesor/materia/<int:detalle_id>/asistencia-movil/estado/', EstadoAsistenciaMovilView.as_view(), name='estado-asistencia-movil'),
    path('profesor/materia/<int:detalle_id>/asistencia-movil/registrados/', EstudiantesRegistradosMovilView.as_view(), name='estudiantes-registrados-movil'),
    
    # Para estudiantes
    path('estudiante/asistencia-movil/registrarse/', RegistrarseAsistenciaMovilView.as_view(), name='registrarse-asistencia-movil'),
]

