from rest_framework import permissions
from django.shortcuts import get_object_or_404
from .models import User


class IsSelfOrAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        user_id = getattr(request, "user_id", None)
        if not user_id:
            return False

        user = get_object_or_404(User, id=user_id)

        # action이 있는 경우 (ViewSet)
        action = getattr(view, "action", None)

        if action == "list":
            return user.global_admin or user.service_account

        if action == "create":
            return user.global_admin or user.service_account

        if action == "retrieve":
            requested_id = view.kwargs.get("pk")
            return (
                user.global_admin
                or user.service_account
                or str(user.id) == str(requested_id)
            )

        # action이 없고 SAFE_METHODS인 경우 (APIView 등)
        if not action and request.method in permissions.SAFE_METHODS:
            return True

        return True  # 나머지는 has_object_permission으로 처리

    def has_object_permission(self, request, view, obj):
        user_id = getattr(request, "user_id", None)
        if not user_id:
            return False

        user = get_object_or_404(User, id=user_id)

        action = getattr(view, "action", None)

        if action in ["update", "partial_update", "destroy"]:
            return (
                str(user.id) == str(obj.id) or user.global_admin or user.service_account
            )

        return True  # retrieve 포함, 이미 has_permission에서 체크했거나 읽기 허용
