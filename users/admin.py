from django.contrib import admin
from .models import User

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('id', 'email', 'name', 'nickname', 'created_at', 'service_account')
    search_fields = ('email', 'name', 'nickname', 'service_account')
    ordering = ('email',)
