from django.contrib import admin
from .models import Dimension, Actividad, DetalleActividad,EntregaTarea
# Register your models here.
admin.site.register(Dimension)
admin.site.register(Actividad)
admin.site.register(DetalleActividad)
admin.site.register(EntregaTarea)