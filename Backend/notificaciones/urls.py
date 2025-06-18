from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'dispositivos', views.DispositivoTokenViewSet, basename='dispositivo')

urlpatterns = [
    path('', include(router.urls)),
    # Las rutas están bien, pero podrías considerar este formato alternativo:
    # path('token/registrar/', views.registrar_token, name='registrar-token'),
    # path('notificaciones/prueba/', views.enviar_prueba, name='enviar-prueba'),
    
    # Sin embargo, las actuales son claras y funcionales:
    path('registrar-token/', views.registrar_token, name='registrar-token'),
    path('enviar-prueba/', views.enviar_prueba, name='enviar-prueba'),
]