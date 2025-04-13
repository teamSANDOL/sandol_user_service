from rest_framework import permissions
from django.shortcuts import get_object_or_404
from .models import User


class IsSelfOrAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        user_id = getattr(request, "user_id", None)
        if not user_id:
            return False

        user = get_object_or_404(User, id=user_id)

        # Create or Retrieve (Read)
        if view.action in ["create", "retrieve"]:
            return user.global_admin or user.service_account

        # List는 일반 사용자에게 허용하지 않음
        if view.action == "list":
            return user.global_admin or user.service_account

        # Update, Destroy 등의 나머지 경우
        return user.global_admin  # 이 시점에서 object_permission에서 본인 여부 확인

    def has_object_permission(self, request, view, obj):
        user_id = getattr(request, "user_id", None)
        if not user_id:
            return False

        requester = get_object_or_404(User, id=user_id)

        if view.action in ["update", "partial_update", "destroy"]:
            return str(requester.id) == str(obj.id) or requester.global_admin

        # retrieve는 has_permission에서 이미 체크됨
        return True
