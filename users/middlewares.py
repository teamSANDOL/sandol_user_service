from django.http import JsonResponse

class SignatureAuthMiddleware:
    """Nginx가 검증한 `X-User-ID`를 Django 요청 객체에 설정"""
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        user_id = request.headers.get("X-User-ID")

        # user_id 헤더가 없으면 401 Unauthorized 반환
        if not user_id:
            return JsonResponse({"error": "Unauthorized"}, status=401)

        # request 객체에 user_id 속성 추가
        setattr(request, "user_id", user_id)

        return self.get_response(request)
