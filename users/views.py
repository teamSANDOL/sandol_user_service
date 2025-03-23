from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, viewsets
from django.shortcuts import get_object_or_404
from .models import User
from .serializers import UserSerializer
from .permissions import IsSelfOrAdmin

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsSelfOrAdmin]  # 커스텀 Permission 적용

    def update(self, request, *args, **kwargs):
        """PUT 요청 시 전체 업데이트, PATCH 요청 시 부분 업데이트"""
        if request.method == "PATCH":
            kwargs['partial'] = True  # PATCH 요청 시 부분 업데이트 활성화
        else:
            kwargs['partial'] = False  # PUT 요청 시 전체 업데이트 강제

        return super().update(request, *args, **kwargs)

class UserGlobalAdminView(APIView):
    """사용자의 global_admin 상태 반환"""
    def get(self, request, id):
        user = get_object_or_404(User, id=id)
        return Response({"is_global_admin": user.global_admin}, status=status.HTTP_200_OK)
