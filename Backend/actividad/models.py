from django.db import models
from usuarios.models import Usuario
# Create your models here.

class Dimension(models.Model):
    nombre = models.CharField(max_length=100, unique=True)
    descripcion = models.TextField(blank=True)

    def __str__(self):
        return self.nombre

class Actividad(models.Model):
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True)
    dimension = models.ForeignKey(Dimension, on_delete=models.CASCADE, related_name='actividades')
    fechaCreacion = models.DateField(auto_now_add=True)  # Fecha de creación automática
    def __str__(self):
        return self.nombre

class EntregaTarea(models.Model):
    actividad = models.ForeignKey(Actividad, on_delete=models.CASCADE, related_name='entregas')
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE, related_name='entregas')
    fecha_entrega = models.DateField(auto_now_add=True)
    entregado = models.BooleanField(default=False) 
    calificacion = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)

class DetalleActividad(models.Model):
    actividad = models.ForeignKey(Actividad, on_delete=models.CASCADE, related_name='detalles_actividad')
    detalle_materia = models.ForeignKey('materia.DetalleMateria', on_delete=models.CASCADE, related_name='detalles_actividad')

    def __str__(self):
        return f"{self.detalle_materia} - {self.actividad}"