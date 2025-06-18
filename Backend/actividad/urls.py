from rest_framework.routers import DefaultRouter
from django.urls import path, include
from .views import (
    DimensionViewSet,
    ActividadViewSet,
    DetalleActividadViewSet,
    CrearActividadConDetalleView,
    ListarActividadesPorMateriaView,
    RegistrarEntregasActividadView,
    ListarEntregasPorActividadView,
    ReporteEntregasView
)

router = DefaultRouter()
router.register(r'dimensiones', DimensionViewSet)
router.register(r'actividades', ActividadViewSet)
router.register(r'detalles-actividad', DetalleActividadViewSet)

urlpatterns = [
    # Incluye las rutas del router
    path('', include(router.urls)),

    # Agrega tus rutas personalizadas
    path('profesor/materia/<int:detalle_id>/crear-actividad/', CrearActividadConDetalleView.as_view(), name='crear-actividad'),
    path('profesor/materia/<int:detalle_id>/actividades/', ListarActividadesPorMateriaView.as_view(), name='listar-actividades-por-materia'),
    path('actividades/<int:actividad_id>/registrar-entregas/', RegistrarEntregasActividadView.as_view(), name='registrar_entregas'),
    path('profesor/materia/<int:detalle_id>/actividad/<int:actividad_id>/entregas/',ListarEntregasPorActividadView.as_view(),name='listar_entregas_por_actividad'),
    path('profesor/materia/<int:detalle_id>/reporte-entregas/',ReporteEntregasView.as_view(),name='reporte_entregas'),
    
]
