# Python 3.11 이미지 사용
FROM python:3.11-slim

# 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 프로젝트 코드 복사
COPY . .

# SQLite DB 저장 경로 생성
RUN mkdir -p ./data && chmod 777 ./data

# STATIC 파일 모으기
ENV DJANGO_SETTINGS_MODULE=config.settings
RUN python manage.py collectstatic --noinput

# ✅ Gunicorn 실행 전 마이그레이션 수행
CMD bash -c "python manage.py makemigrations && python manage.py migrate && gunicorn config.wsgi:application --bind 0.0.0.0:8000 --env SCRIPT_NAME=/user"
