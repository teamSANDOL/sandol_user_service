from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet, UserGlobalAdminView

router = DefaultRouter()
router.register(r'users', UserViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('users/<int:id>/is_global_admin/', UserGlobalAdminView.as_view(), name='user-is-global-admin'),
]
