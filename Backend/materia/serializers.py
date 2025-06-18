from rest_framework import serializers
from .models import (
    Nivel, Materia, 
     DetalleMateria, Asistencia
)

class NivelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Nivel
        fields = '__all__'

class MateriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Materia
        fields = '__all__'


class DetalleMateriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = DetalleMateria
        fields = '__all__'

class AsistenciaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Asistencia
        fields = '__all__'