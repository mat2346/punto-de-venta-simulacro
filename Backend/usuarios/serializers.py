from rest_framework import serializers
from .models import Usuario, Rol
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class UsuarioSerializer(serializers.ModelSerializer):
    rol = serializers.SerializerMethodField()
    rol_id = serializers.PrimaryKeyRelatedField(
        queryset=Rol.objects.all(),
        source='rol',
        write_only=True,
        required=False
    )

    class Meta:
        model = Usuario
        fields = '__all__'
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def get_rol(self, obj):
        return {
            'id': obj.rol.id,
            'nombre': obj.rol.nombre
        } if obj.rol else None

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        rol = validated_data.pop('rol', None)
        groups = validated_data.pop('groups', [])
        user_permissions = validated_data.pop('user_permissions', [])

        user = Usuario(**validated_data)

        if password:
            user.set_password(password)

        if rol:
            user.rol = rol

        user.save()

        if groups:
            user.groups.set(groups)  # ✅ CORRECTO

        if user_permissions:
            user.user_permissions.set(user_permissions)  # ✅ CORRECTO

        return user

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        rol = validated_data.pop('rol', None)
        groups = validated_data.pop('groups', None)
        user_permissions = validated_data.pop('user_permissions', None)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        if password:
            instance.set_password(password)  # importante encriptar la contraseña al actualizar

        if rol is not None:
            instance.rol = rol

        instance.save()

        if groups is not None:
            instance.groups.set(groups)

        if user_permissions is not None:
            instance.user_permissions.set(user_permissions)

        return instance

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = 'codigo'
