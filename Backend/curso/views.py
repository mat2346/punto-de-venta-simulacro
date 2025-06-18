from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets
from .models import Curso, Paralelo
from .serializers import CursoSerializer, ParaleloSerializer

class ParaleloViewSet(viewsets.ModelViewSet):
    queryset = Paralelo.objects.all()
    serializer_class = ParaleloSerializer

class CursoViewSet(viewsets.ModelViewSet):
    queryset = Curso.objects.all()
    serializer_class = CursoSerializer