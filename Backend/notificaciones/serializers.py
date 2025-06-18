from rest_framework import serializers
from .models import DispositivoToken

class DispositivoTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DispositivoToken
        fields = ['id', 'token', 'activo', 'creado']
        read_only_fields = ['id', 'creado']