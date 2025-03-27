from rest_framework import permissions
from django.shortcuts import get_object_or_404
from .models import User

class IsSelfOrAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        if view.action == "list":
            user = get_object_or_404(User, id=request.user_id)
            return user.global_admin

        if view.action == "create":
            user = get_object_or_404(User, id=request.user_id)
            return (user.is_service_account or user.global_admin)

        return request.user_id is not None

    def has_object_permission(self, request, view, obj):
        requester = get_object_or_404(User, id=request.user_id)
        return str(requester.id) == str(obj.id) or requester.global_admin
