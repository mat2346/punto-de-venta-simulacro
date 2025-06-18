from rest_framework import serializers
from .models import Gestion, Libreta

class GestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Gestion
        fields = '__all__'

class LibretaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Libreta
        fields = '__all__'