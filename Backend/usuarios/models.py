from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager

class Permiso(models.Model):
    nombre = models.CharField(max_length=50, unique=True)

    def __str__(self):
        return self.nombre

class Rol(models.Model):
    nombre = models.CharField(max_length=20, unique=True)
    permisos = models.ManyToManyField(Permiso, related_name='roles')

    def __str__(self):
        return self.nombre

class UsuarioManager(BaseUserManager):
    def create_user(self, ci, nombre, sexo, fecha_nacimiento, password=None, **extra_fields):
        if not ci:
            raise ValueError('El campo CI es obligatorio')
        user = self.model(
            ci=ci,
            nombre=nombre,
            sexo=sexo,
            fecha_nacimiento=fecha_nacimiento,
            **extra_fields
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, ci, nombre, sexo, fecha_nacimiento, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(ci, nombre, sexo, fecha_nacimiento, password, **extra_fields)

class Usuario(AbstractBaseUser, PermissionsMixin):
    SEXO_CHOICES = (
        ('M', 'Masculino'),
        ('F', 'Femenino'),
    )
    id = models.AutoField(primary_key=True)
    ci = models.BigIntegerField(unique=True)  # Ahora es numérico
    nombre = models.CharField(max_length=100)
    sexo = models.CharField(max_length=1, choices=SEXO_CHOICES)
    fecha_nacimiento = models.DateField()
    estado = models.BooleanField(default=True)
    codigo = models.BigIntegerField(unique=True)  # Ahora es numérico
    rol = models.ForeignKey(Rol, on_delete=models.SET_NULL, null=True, blank=True, related_name='usuarios')
    fcm_token = models.TextField(null=True, blank=True)
    tutor = models.ForeignKey(
        'self',
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='estudiantes'
    )  # Solo se usa si el usuario es estudiante
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
   
    USERNAME_FIELD = 'codigo'
    REQUIRED_FIELDS = ['ci', 'nombre', 'sexo', 'fecha_nacimiento']

    objects = UsuarioManager()

    def __str__(self):
        return self.nombre