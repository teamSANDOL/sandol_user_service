from django.db import models

class User(models.Model):
    """Superuser와 별도로 관리되는 일반 사용자 모델"""
    email = models.EmailField(unique=True)
    name = models.CharField(max_length=100)
    nickname = models.CharField(max_length=50, unique=True, null=True, blank=True)
    global_admin = models.BooleanField(default=False)
    service_account = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.email
