from django.db import models
from usuarios.models import Usuario
from materia.models import DetalleMateria
class Gestion(models.Model):
    nombre = models.CharField(max_length=50, unique=True)

    def __str__(self):
        return self.nombre

class Libreta(models.Model):
    estudiante = models.ForeignKey(Usuario, on_delete=models.CASCADE, related_name='libretas')
    # Si quieres relacionar con Materia:
    # materia = models.ForeignKey('materia.Materia', on_delete=models.CASCADE, related_name='libretas')
    # Si necesitas DetalleMateria:
    gestion = models.ForeignKey(Gestion, on_delete=models.CASCADE, related_name='libretas')
    detalle_materia = models.ForeignKey(DetalleMateria, on_delete=models.CASCADE, related_name='libretas', null=True, blank=True)
    nota = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)  # Campo para la notaAdd commentMore actions

    def __str__(self):
        return f"Libreta de {self.estudiante} - {self.gestion} - Nota: {self.nota}"