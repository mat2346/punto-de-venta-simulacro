from django.contrib import admin
from .models import Usuario, Rol, Permiso

admin.site.register(Usuario)
admin.site.register(Rol)
admin.site.register(Permiso)
# Register your models here.
