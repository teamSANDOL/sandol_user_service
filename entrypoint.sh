#!/bin/bash
set -e

# DB 초기화
python manage.py migrate --fake-initial --noinput

# DB가 없거나 비어 있으면 더미 데이터 로드
if [ ! -f "./data/db.sqlite3" ] || ! sqlite3 ./data/db.sqlite3 "SELECT COUNT(*) FROM auth_user;" | grep -q '[1-9]'; then
    echo "🟡 Loading fixture data..."
    python manage.py loaddata ./db/temp_db_data.json || echo "⚠️ loaddata failed, possibly already applied."
fi

# 서버 실행
exec gunicorn config.wsgi:application --bind 0.0.0.0:8000 --env SCRIPT_NAME=/user
