from rest_framework import serializers
from .models import Dimension, Actividad, DetalleActividad, EntregaTarea

class DimensionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dimension
        fields = '__all__'

class ActividadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Actividad
        fields = '__all__'

class DetalleActividadSerializer(serializers.ModelSerializer):
    class Meta:
        model = DetalleActividad
        fields = '__all__'

class EntregaTareaSerializer(serializers.ModelSerializer):
    class Meta:
        model = EntregaTarea
        fields = '__all__'
