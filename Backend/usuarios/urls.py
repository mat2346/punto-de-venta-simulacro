from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    UsuarioViewSet, LoginView, LogoutView, CambiarContrasenaView,
    CustomTokenObtainPairView, EstudiantesDelTutorView, ResumenAlumnoView,
    ResumenHijoTutorView, RendimientoDetalladoHijoView
)
from . import controller_firebase as firebase_controller


from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def actualizar_fcm_token(request):
    fcm_token = request.data.get('fcm_token')
    if fcm_token:
        request.user.fcm_token = fcm_token
        request.user.save(update_fields=['fcm_token'])
        return Response({'mensaje': 'FCM token actualizado'})
    return Response({'error': 'FCM token requerido'}, status=400)

router = DefaultRouter()
router.register(r'usuarios', UsuarioViewSet, basename='usuario')

urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('cambiar-contrasena/', CambiarContrasenaView.as_view(), name='cambiar_contrasena'),
    path('tutor/estudiantes/', EstudiantesDelTutorView.as_view(), name='estudiantes-tutor'),
    path('alumno/resumen/', ResumenAlumnoView.as_view(), name='alumno_resumen'),
    path('tutor/hijo/<int:estudiante_id>/resumen/', ResumenHijoTutorView.as_view(), name='resumen_hijo_tutor'),
    path('tutor/hijo/<int:estudiante_id>/rendimiento/', RendimientoDetalladoHijoView.as_view(), name='rendimiento_hijo_tutor'),
    
    # 🔥 URLs de notificaciones
    path('notificacion/crear/<int:id>/', firebase_controller.crear_notificacion_uni, name='crear_notificacion_uni'),
    path('profesor/enviar-notificacion/', firebase_controller.enviar_notificacion_masiva, name='enviar_notificacion_masiva'),
    path('profesor/destinatarios/', firebase_controller.obtener_destinatarios, name='obtener_destinatarios'),
    path('notificacion/simple/<int:usuario_id>/', firebase_controller.enviar_notificacion_simple, name='notificacion_simple'),
    
    path('usuario/fcm-token/', actualizar_fcm_token, name='actualizar_fcm_token'),
]

urlpatterns += router.urls

urlpatterns += [
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
