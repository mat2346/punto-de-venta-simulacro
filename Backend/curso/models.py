from django.db import models

class Paralelo(models.Model):
    nombre = models.CharField(max_length=10, unique=True)

    def __str__(self):
        return self.nombre

class Curso(models.Model):
    nombre = models.CharField(max_length=100)
    paralelo = models.ForeignKey(Paralelo, on_delete=models.CASCADE, related_name='cursos')

    def __str__(self):
        return f"{self.nombre} - {self.paralelo}"