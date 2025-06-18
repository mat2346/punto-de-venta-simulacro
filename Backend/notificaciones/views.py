from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import DispositivoToken
from .serializers import DispositivoTokenSerializer
from .firebase import enviar_notificacion, enviar_notificacion_multiple

class DispositivoTokenViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = DispositivoTokenSerializer
    
    def get_queryset(self):
        # Solo devuelve los tokens del usuario autenticado
        return DispositivoToken.objects.filter(usuario=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)

@api_view(['POST'])
# @permission_classes([IsAuthenticated])  # Comentado para pruebas
def registrar_token(request):
    """Registrar token de dispositivo (sin autenticación para pruebas)"""
    token = request.data.get('token')
    
    if not token:
        return Response({"error": "Token no proporcionado"}, status=status.HTTP_400_BAD_REQUEST)
    
    # Para pruebas, si no hay usuario autenticado, usar un usuario existente
    if request.user.is_anonymous:
        # Importa el modelo de Usuario
        from django.contrib.auth import get_user_model
        User = get_user_model()
        
        try:
            # Usar un usuario existente
            usuario = User.objects.first()
            if not usuario:
                return Response({"error": "No hay usuarios en el sistema"}, 
                              status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        except Exception as e:
            return Response({"error": f"Error: {str(e)}"}, 
                          status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    else:
        usuario = request.user
    
    # Buscar si ya existe el token
    token_existente = DispositivoToken.objects.filter(token=token).first()
    
    if token_existente:
        # Actualizar token existente
        token_existente.usuario = usuario
        token_existente.activo = True
        token_existente.save()
        mensaje = "Token actualizado correctamente"
    else:
        # Crear nuevo token - SIN incluir 'dispositivo'
        DispositivoToken.objects.create(
            usuario=usuario,
            token=token,
            activo=True
        )
        mensaje = "Token registrado correctamente"
    
    return Response({"mensaje": mensaje}, status=status.HTTP_201_CREATED)

@api_view(['POST'])
# @permission_classes([IsAuthenticated])  # Comentado para pruebas
def enviar_prueba(request):
    """Enviar notificación de prueba"""
    # Verificar si hay un token específico para pruebas
    token = request.data.get('token')
    
    # Si se proporciona un token específico, usarlo en lugar de buscar en la base de datos
    if token:
        # Enviar directamente al token proporcionado
        titulo = request.data.get('title', "Notificación de prueba")
        mensaje = request.data.get('message', "¡Esta es una notificación de prueba enviada desde el servidor!")
        datos_extra = request.data.get('data', {})
        
        try:
            # Enviar notificación individual
            resultado = enviar_notificacion(token, titulo, mensaje, datos_extra)
            return Response(resultado)
        except Exception as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    # Si no hay token proporcionado y el usuario está autenticado, buscar en base de datos
    if not request.user.is_anonymous:
        tokens = DispositivoToken.objects.filter(
            usuario=request.user,
            activo=True
        ).values_list('token', flat=True)
        
        if not tokens:
            return Response({"error": "No hay dispositivos registrados"}, status=status.HTTP_404_NOT_FOUND)
        
        # Obtener parámetros o usar valores predeterminados
        titulo = request.data.get('title', "Notificación de prueba")
        mensaje = request.data.get('message', "¡Esta es una notificación de prueba enviada desde el servidor!")
        datos_extra = request.data.get('data', {})
        
        try:
            resultado = enviar_notificacion_multiple(list(tokens), titulo, mensaje, datos_extra)
            return Response(resultado)
        except Exception as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    else:
        # Usuario no autenticado y no proporcionó token
        return Response({"error": "Debe proporcionar un token o autenticarse"}, status=status.HTTP_400_BAD_REQUEST)
# Create your views here.
