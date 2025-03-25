from django.http import JsonResponse
from django.conf import settings


class SignatureAuthMiddleware:
    """Nginx가 검증한 `X-User-ID`를 Django 요청 객체에 설정"""
    def __init__(self, get_response):
        self.get_response = get_response
        self.whitelist = getattr(settings, "SIGNATURE_AUTH_WHITELIST", [])

    def __call__(self, request):
        # 화이트리스트 경로는 인증 생략
        if any(request.path.startswith(path) for path in self.whitelist):
            return self.get_response(request)

        user_id = request.headers.get("X-User-ID")

        if not user_id:
            return JsonResponse({"error": "Unauthorized"}, status=401)

        setattr(request, "user_id", user_id)
        return self.get_response(request)
