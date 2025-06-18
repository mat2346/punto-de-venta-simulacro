from django.db import models
from usuarios.models import Usuario
from actividad.models import Actividad
from curso.models import Curso, Paralelo 


class Nivel(models.Model):
    OPCIONES_NIVEL = (
        ('primaria', 'Primaria'),
        ('secundaria', 'Secundaria'),
    )
    nombre = models.CharField(max_length=20, choices=OPCIONES_NIVEL, unique=True)

    def __str__(self):
        return self.get_nombre_display()

class Materia(models.Model):
    nombre = models.CharField(max_length=100)
    nivel = models.ForeignKey(Nivel, on_delete=models.CASCADE, related_name='materias')

    def __str__(self):
        return f"{self.nombre} ({self.nivel})"


class DetalleMateria(models.Model):
    profesor = models.ForeignKey(
        Usuario,
        on_delete=models.CASCADE,
        related_name='detalles_materia',
        help_text="Profesor asignado a la materia"
    )
    materia = models.ForeignKey(Materia, on_delete=models.CASCADE, related_name='detalles_materia')
    curso = models.ForeignKey(Curso, on_delete=models.CASCADE, related_name='detalles_materia')
    actividad = models.ForeignKey(Actividad, on_delete=models.SET_NULL, null=True, blank=True, related_name='detalles_materia')
    
    def __str__(self):
        return f"{self.profesor} - {self.materia} - Actividad: {self.actividad} "

# 🔥 MANTENER EL MODELO ORIGINAL INTACTO
class Asistencia(models.Model):
    detalle_materia = models.ForeignKey(DetalleMateria, on_delete=models.CASCADE, related_name='asistencias')
    estudiante = models.ForeignKey(Usuario, on_delete=models.CASCADE, related_name='asistencias')
    fecha = models.DateField(auto_now_add=True)
    presente = models.BooleanField(default=False)

    def __str__(self):
        return f"Asistencia en {self.detalle_materia} ({self.fecha})"


# 🔥 NUEVOS MODELOS PARA ASISTENCIA MÓVIL (PARALELOS)
class SesionAsistenciaMovil(models.Model):
    """Modelo para las sesiones de asistencia móvil (separado del sistema original)"""
    detalle_materia = models.ForeignKey(DetalleMateria, on_delete=models.CASCADE, related_name='sesiones_movil')
    codigo = models.CharField(max_length=6, unique=True, help_text="Código único de 6 dígitos")
    fecha_inicio = models.DateTimeField(auto_now_add=True)
    fecha_fin = models.DateTimeField(help_text="Cuando expira la sesión")
    activa = models.BooleanField(default=True)
    duracion_minutos = models.IntegerField(default=15, help_text="Duración en minutos")
    
    # Metadatos adicionales
    total_registros = models.IntegerField(default=0, help_text="Cuántos estudiantes se registraron")
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-fecha_inicio']
        verbose_name = "Sesión de Asistencia Móvil"
        verbose_name_plural = "Sesiones de Asistencia Móvil"
    
    def __str__(self):
        estado = "Activa" if self.esta_activa else "Inactiva"
        return f"Sesión {self.codigo} - {self.detalle_materia.materia.nombre} ({estado})"
    
    @property
    def esta_activa(self):
        from django.utils import timezone
        return self.activa and timezone.now() <= self.fecha_fin
    
    @property
    def tiempo_restante_minutos(self):
        from django.utils import timezone
        if not self.esta_activa:
            return 0
        diferencia = self.fecha_fin - timezone.now()
        return max(0, int(diferencia.total_seconds() / 60))

class RegistroAsistenciaMovil(models.Model):
    """Registro individual de cada estudiante que se registra via móvil"""
    sesion = models.ForeignKey(SesionAsistenciaMovil, on_delete=models.CASCADE, related_name='registros')
    estudiante = models.ForeignKey(Usuario, on_delete=models.CASCADE, related_name='registros_movil')
    fecha_registro = models.DateTimeField(auto_now_add=True)
    
    # Datos adicionales del registro
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    ubicacion_lat = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    ubicacion_lng = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    
    class Meta:
        unique_together = ['sesion', 'estudiante']  # Un estudiante solo puede registrarse una vez por sesión
        ordering = ['-fecha_registro']
        verbose_name = "Registro de Asistencia Móvil"
        verbose_name_plural = "Registros de Asistencia Móvil"
    
    def __str__(self):
        return f"{self.estudiante.nombre} - Sesión {self.sesion.codigo} ({self.fecha_registro.strftime('%H:%M')})"

    def save(self, *args, **kwargs):
        # Actualizar contador de la sesión
        if not self.pk:  # Solo en creación
            super().save(*args, **kwargs)
            self.sesion.total_registros = self.sesion.registros.count()
            self.sesion.save(update_fields=['total_registros'])
        else:
            super().save(*args, **kwargs)