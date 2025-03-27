"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path, include
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

from config.views import generate_signature

schema_view = get_schema_view(
    openapi.Info(
        title="User API",
        default_version="v1",
        description="""
### 🛡️ 인증 방식 안내

🔐 이 API는 **HMAC 기반 서명 인증**을 사용합니다.

- 모든 요청에는 다음 헤더가 포함되어야 합니다:
  - `X-User-ID`: 요청자 사용자 ID
  - `X-Signature`: SECRET_KEY와 X-User-ID를 기반으로 생성된 HMAC 서명

- `X-Signature`는 [**/test/signature?user_id=xxx**](./test/signature?user_id=1) API에서 획득할 수 있습니다 (DEBUG 모드에서만 사용 가능)

---

### 예시

```bash
curl -H "X-User-ID: 1" -H "X-Signature: abc123..." https://your.domain/api/...
```

""",
    ),
    public=True,
    permission_classes=[permissions.AllowAny],
)

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("users.urls")),  # User API 엔드포인트 추가
    path("test/signature", generate_signature),  # Signature 생성 엔드포인트 추가
    # Swagger UI
    path(
        "swagger/",
        schema_view.with_ui("swagger", cache_timeout=0),
        name="schema-swagger-ui",
    ),
    path("redoc/", schema_view.with_ui("redoc", cache_timeout=0), name="schema-redoc"),
]
