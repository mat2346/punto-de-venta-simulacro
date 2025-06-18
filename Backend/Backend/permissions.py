from rest_framework.permissions import BasePermission

class SoloUsuariosConRol(BasePermission):
    """
    Permite el acceso solo a usuarios autenticados con un rol específico.
    Cambia los nombres de rol según tus necesidades.
    """
    allowed_roles = ['profesor', 'admin']  # Cambia aquí los roles permitidos

    def has_permission(self, request, view):
        user = request.user
        return (
            user.is_authenticated and
            hasattr(user, 'rol') and
            user.rol is not None and
            user.rol.nombre in self.allowed_roles
        )