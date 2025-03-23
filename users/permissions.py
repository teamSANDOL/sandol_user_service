from rest_framework import permissions
from django.shortcuts import get_object_or_404
from .models import User

class IsSelfOrAdmin(permissions.BasePermission):
    """
    - 개별 사용자 조회(GET /api/users/{id}/)는 자신의 정보만 가능, 단 global_admin이면 전체 접근 허용
    - 전체 사용자 목록 조회(GET /api/users/)는 global_admin만 가능
    """

    def has_permission(self, request, view):
        """전체 목록 조회(GET /api/users/)는 global_admin=True 사용자만 가능"""
        if view.action == "list":  # 전체 사용자 목록 요청
            # user_id 기반으로 요청한 사용자를 가져옴
            user = get_object_or_404(User, id=request.user_id)
            return user.global_admin  # global_admin=True인 경우만 허용

        return request.user_id is not None  # 그 외 요청은 user_id가 있으면 허용

    def has_object_permission(self, request, view, obj):
        """개별 사용자 정보 조회(GET /api/users/{id}/)는 자기 자신이거나 global_admin=True인 경우 허용"""
        return str(request.user_id) == str(obj.id) or obj.global_admin
