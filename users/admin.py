from django.contrib import admin
from .models import User

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('id', 'email', 'name', 'nickname', 'created_at')
    search_fields = ('email', 'name', 'nickname')
    ordering = ('email',)
