from rest_framework import permissions
from django.shortcuts import get_object_or_404
from .models import User


class IsSelfOrAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        user_id = getattr(request, "user_id", None)
        if not user_id:
            return False

        user = get_object_or_404(User, id=user_id)

        # List는 일반 사용자에게 허용하지 않음
        if view.action == "list":
            user = get_object_or_404(User, id=request.user_id)
            return user.global_admin or user.service_account

        if view.action == "create":
            user = get_object_or_404(User, id=request.user_id)
            return user.service_account or user.global_admin

        # 단일 객체 조회(retrieve)일 때, 자신이거나 관리자/서비스 계정이면 허용
        if view.action == "retrieve":
            user = get_object_or_404(User, id=request.user_id)
            requested_id = view.kwargs.get("pk")
            return (
                user.global_admin
                or user.service_account
                or str(request.user_id) == str(requested_id)
            )

        # 그 외 인증된 사용자만 허용 (update, partial_update 등은 object_permission으로 처리)
        return request.user_id is not None

    def has_object_permission(self, request, view, obj):
        user_id = getattr(request, "user_id", None)
        if not user_id:
            return False

        # 객체 단위로도 자신이거나 관리자만 허용
        user: User = get_object_or_404(User, id=user_id)

        if view.action in ["update", "partial_update", "destroy"]:
            return (
                str(user.id) == str(obj.id) or user.global_admin or user.service_account
            )

        # retrieve는 has_permission에서 이미 체크됨
        return True
