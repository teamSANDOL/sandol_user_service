from django.contrib import admin
from .models import User

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('id', 'email', 'name', 'nickname', 'created_at', 'global_admin', 'service_account')
    search_fields = ('email', 'name', 'nickname', 'global_admin', 'service_account')
    ordering = ('email',)
