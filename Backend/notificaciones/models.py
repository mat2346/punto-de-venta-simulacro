from django.db import models

from usuarios.models import Usuario

class DispositivoToken(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE, related_name='dispositivos')
    token = models.CharField(max_length=255)
    activo = models.BooleanField(default=True)
    creado = models.DateTimeField(auto_now_add=True)
    actualizado = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('usuario', 'token')

    def __str__(self):
        return f"{self.usuario.nombre} - {self.token[:10]}..."

