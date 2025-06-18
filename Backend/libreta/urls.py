from rest_framework.routers import DefaultRouter
from .views import GestionViewSet, LibretaViewSet

router = DefaultRouter()
router.register(r'gestiones', GestionViewSet, basename='gestion')
router.register(r'libretas', LibretaViewSet, basename='libreta')

urlpatterns = router.urls