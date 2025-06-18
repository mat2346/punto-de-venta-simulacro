from django.apps import AppConfig


class ActividadConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'actividad'
    
    def ready(self):
        """
        Se ejecuta cuando la aplicación está lista.
        Aquí importamos los signals para que se registren.
        """
        import actividad.signals  # Importar el archivo de signals