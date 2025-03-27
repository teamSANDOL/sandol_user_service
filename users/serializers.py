import re
from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'name', 'nickname', 'global_admin', 'is_service_account', 'created_at']
        read_only_fields = ['id', 'created_at', 'global_admin', 'is_service_account']
        extra_kwargs = {
            'nickname': {'required': False},
            'global_admin': {'read_only': True},
            'is_service_account': {'read_only': True},
        }

    def validate_email(self, value):
        """이메일 필드 유효성 검사"""
        if not value:
            raise serializers.ValidationError("이메일은 필수입니다.")
        if not re.match(r"[^@]+@[^@]+\.[^@]+", value):
            raise serializers.ValidationError("유효한 이메일 주소를 입력하세요.")
        return value

    def validate_name(self, value):
        """이름 필드 유효성 검사"""
        if not value:
            raise serializers.ValidationError("이름은 필수입니다.")
        return value

    def create(self, validated_data):
        """POST 요청에서는 email과 name이 필수"""
        if 'email' not in validated_data or 'name' not in validated_data:
            raise serializers.ValidationError("email과 name은 필수 입력입니다.")
        return super().create(validated_data)

    def update(self, instance, validated_data):
        """PUT 요청에서는 부분 업데이트 허용 (partial=True)"""
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance
