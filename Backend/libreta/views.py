from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets
from .models import Gestion, Libreta
from .serializers import GestionSerializer, LibretaSerializer

class GestionViewSet(viewsets.ModelViewSet):
    queryset = Gestion.objects.all()
    serializer_class = GestionSerializer

class LibretaViewSet(viewsets.ModelViewSet):
    queryset = Libreta.objects.all()
    serializer_class = LibretaSerializer