from django.contrib.auth.backends import ModelBackend
from .models import Usuario

class CodigoBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            user = Usuario.objects.get(codigo=username)
            if user.check_password(password):
                return user
        except Usuario.DoesNotExist:
            return None