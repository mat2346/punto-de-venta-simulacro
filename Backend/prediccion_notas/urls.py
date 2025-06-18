from django.urls import path
from . import views

urlpatterns = [
    # Puedes usar la vista basada en función
    path('predecir/', views.prediccion_api, name='prediccion_api'),
    
    # O la vista basada en clase
    # path('prediccion/', views.PrediccionNotaView.as_view(), name='prediccion_vista'),
]