# config/views.py

from django.conf import settings
from django.http import JsonResponse
from rest_framework.decorators import api_view
import hmac, hashlib, base64, os

@api_view(["GET"])
def generate_signature(request):
    if not settings.DEBUG:
        return JsonResponse({"error": "Not allowed in production"}, status=403)

    user_id = request.headers.get("X-User-ID")
    if not user_id:
        return JsonResponse({"error": "X-User-ID header is required"}, status=400)

    secret_key = os.environ.get("SECRET_KEY")
    if not secret_key:
        return JsonResponse({"error": "SECRET_KEY not set"}, status=500)

    raw = hmac.new(
        secret_key.encode(),
        user_id.encode(),
        hashlib.sha256
    ).digest()

    signature = base64.urlsafe_b64encode(raw).decode().rstrip('=')

    return JsonResponse({
        "user_id": user_id,
        "signature": signature
    })
