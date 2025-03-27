from django.utils.deprecation import MiddlewareMixin
from django.http import JsonResponse
from django.conf import settings


class SignatureAuthMiddleware(MiddlewareMixin):
    def __init__(self, get_response=None):
        super().__init__(get_response)
        self.whitelist = getattr(settings, "SIGNATURE_AUTH_WHITELIST", [])

    def process_view(self, request, view_func, view_args, view_kwargs):
        # 화이트리스트 경로는 인증 생략
        if any(request.path.startswith(path) for path in self.whitelist):
            return None

        user_id = request.headers.get("X-User-ID")
        if not user_id:
            if settings.DEBUG:
                print(f"[DEBUG] {request.path} - Unauthorized\n header: {request.headers}")
            return JsonResponse({"error": "Unauthorized"}, status=401)

        setattr(request, "user_id", user_id)
        return None
