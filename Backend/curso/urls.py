from rest_framework.routers import DefaultRouter
from .views import CursoViewSet, ParaleloViewSet

router = DefaultRouter()
router.register(r'paralelos', ParaleloViewSet, basename='paralelo')
router.register(r'cursos', CursoViewSet, basename='curso')

urlpatterns = router.urls