# Keycloak 로그인 테마 (client별 분리)

Keycloak은 client마다 다른 로그인 테마를 쓸 수 있다. 이 저장소에는 두 테마가 있다.

| 테마 | 경로 | 용도 |
| --- | --- | --- |
| `handol` | `web/keycloak-theme/handol/login/` | 앱 client. Figma 디자인, 서비스명 '한돌이' |
| `sandori` | `web/keycloak-theme/sandori/` | 챗봇 client(auth-relay 경유)와 realm 기본값. 기존 디자인, '산돌이' |

- 이메일 테마는 realm 단위라서 `sandori/email`만 있고 client별로 나뉘지 않는다.
- 테마 디렉터리 이름은 realm·client 설정이 참조하므로 바꾸지 않는다.

## client 구분

| 구분 | clientId (테스트 서버 realm 기준) | 근거 |
| --- | --- | --- |
| 앱 | `handori-app` | 공개 client, redirect URI가 앱 커스텀 스킴 |
| 챗봇 | `sandol-kakao-bot` | relay `clients.json`의 client_id, redirect URI가 `/relay/oidc/callback` |

운영 realm의 clientId가 다르면 아래 `<앱 client>`, `<챗봇 client>`를 운영 값으로 바꿔 적용한다.

## 운영 적용 절차

1. 테마를 배포한다. 서브모듈을 갱신하면 `./sandol_user_service/web/keycloak-theme`가 컨테이너의 `/opt/keycloak/themes`에 마운트된다.
2. Admin Console에서 설정한다.
   - Clients -> `<앱 client>` -> Settings -> Login settings -> Login theme = `handol`
   - Clients -> `<챗봇 client>` -> Login theme = `sandori` (비워 두면 realm 기본값을 따른다)
   - Realm settings -> Themes의 Login theme(realm 기본값)은 바꾸지 않는다.
3. 테마 캐시를 지우고 Keycloak을 재시작한다. 재시작만 하면 브라우저에 옛 CSS가 남는다.

```bash
docker exec keycloak rm -rf /opt/keycloak/data/tmp/kc-gzip-cache
docker restart keycloak
```

## kcadm 예시

값은 placeholder다. 관리자 비밀번호는 환경 변수로 넘기고 명령 줄에 적지 않는다.

```bash
docker exec -e KC_ADMIN_PW keycloak sh -c '
  /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/auth \
    --realm master --user <admin-user> --password "$KC_ADMIN_PW"
  APP_ID=$(/opt/keycloak/bin/kcadm.sh get clients -r <realm> -q clientId=<앱 client> --fields id --format csv --noquotes)
  BOT_ID=$(/opt/keycloak/bin/kcadm.sh get clients -r <realm> -q clientId=<챗봇 client> --fields id --format csv --noquotes)
  /opt/keycloak/bin/kcadm.sh update clients/$APP_ID -r <realm> -s attributes.login_theme=handol
  /opt/keycloak/bin/kcadm.sh update clients/$BOT_ID -r <realm> -s attributes.login_theme=sandori
'
```

되돌리기: 앱 client의 `attributes.login_theme`을 `sandori`로 바꾸거나 값을 비운 뒤 캐시를 지우고 재시작한다.
