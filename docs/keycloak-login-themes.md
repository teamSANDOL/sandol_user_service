# Keycloak 로그인 테마 (client별 분리)

Keycloak은 client마다 다른 로그인 테마를 쓸 수 있다. 이 저장소에는 세 테마가 있다.

| 테마 | 경로 | 용도 |
| --- | --- | --- |
| `handol` | `web/keycloak-theme/handol/login/` | 앱 client. Figma 디자인, 서비스명 '한돌이' |
| `handol-app` | `web/keycloak-theme/handol-app/login/` | 앱 client `handol-app` 전용. `handol`을 부모로 두고 로그인·가입·비밀번호 찾기 화면만 앱 디자인(Figma 2:3964·2:4015·2:4057)으로 덮어쓴다 |
| `sandori` | `web/keycloak-theme/sandori/` | 챗봇 client(auth-relay 경유)와 realm 기본값. 기존 디자인, '산돌이' |

- 이메일 테마는 realm 단위라서 `sandori/email`만 있고 client별로 나뉘지 않는다.
- 테마 디렉터리 이름은 realm·client 설정이 참조하므로 바꾸지 않는다.

## client 구분

| 구분 | clientId | 근거 |
| --- | --- | --- |
| 앱 | `handol-app` | 앱 로그인 client |
| 챗봇 | `sandol-kakao-bot` | relay `clients.json`의 client_id, redirect URI가 `/relay/oidc/callback` |


## 운영 적용 절차

1. 테마를 배포한다. 서브모듈을 갱신하면 `./sandol_user_service/web/keycloak-theme`가 컨테이너의 `/opt/keycloak/themes`에 마운트된다.
2. Admin Console에서 설정한다.
   - Clients -> `handol-app` -> Settings -> Login settings -> Login theme = `handol-app` (웹용으로 `handol`을 쓰는 다른 client는 그대로 둔다)
   - Clients -> `sandol-kakao-bot` -> Login theme = `sandori` (비워 두면 realm 기본값을 따른다)
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
  APP_ID=$(/opt/keycloak/bin/kcadm.sh get clients -r <realm> -q clientId=handol-app --fields id --format csv --noquotes)
  BOT_ID=$(/opt/keycloak/bin/kcadm.sh get clients -r <realm> -q clientId=sandol-kakao-bot --fields id --format csv --noquotes)
  /opt/keycloak/bin/kcadm.sh update clients/$APP_ID -r <realm> -s attributes.login_theme=handol-app
  /opt/keycloak/bin/kcadm.sh update clients/$BOT_ID -r <realm> -s attributes.login_theme=sandori
'
```

되돌리기: 앱 client의 `attributes.login_theme`을 `sandori`로 바꾸거나 값을 비운 뒤 캐시를 지우고 재시작한다.

## handol-app 테마

- 부모 `handol`은 수정하지 않는다. `handol-app/login/`에는 바뀐 템플릿·CSS·JS·메시지만 있고 나머지는 상속한다.
- 화면 구성: 로그인(소셜·시작화면·로그인 상태 유지 없음, 뒤로 화살표 없음), 회원가입 1→2단계(같은 form, 2단계에서 동의 3개), 비밀번호 찾기, 정보 확인·계정 연결·약관·로그아웃·안내.
- 필수 동의 3개(이용약관·개인정보 수집·이용·국외 이전)는 서버에 `termsAccepted` 하나로 합쳐 보낸다(3개 모두 체크해야 값이 전송됨). user profile 속성은 추가하지 않는다.
- 약관·처리방침 주소는 `handol-app/login/theme.properties`의 `termsUrl`, `privacyPolicyUrl` 두 줄만 고치면 된다.
- 로그인 오류 문구 중 `accountTemporarilyDisabledMessage`는 Keycloak이 임시 잠김일 때만 쓰며, 기본값은 잘못된 비밀번호와 같은 문구다. 이 테마는 잠김 안내로 바꿨으므로 잠김 여부가 화면에 드러난다. 원치 않으면 `messages_*.properties`에서 이 키를 지운다.
- 앱 client 요건: public client, Standard flow, PKCE S256 필수, redirect URI `app.handol.student://oauthredirect`·`kr.sandori.handori://oauthredirect`, offline_access 허용.

### 적용

```bash
# 서브모듈 갱신 후 테마 캐시를 지우고 재시작
docker exec keycloak rm -rf /opt/keycloak/data/tmp/kc-gzip-cache
docker restart keycloak
# client 의 Login theme 을 handol-app 으로 (위 kcadm 예시에서 attributes.login_theme=handol-app)
```

### 롤백

`handol-app` client 의 `attributes.login_theme`을 `handol`(이전 값)으로 되돌리고 캐시를 지운 뒤 재시작한다. 테마 디렉터리를 지워도 되며 다른 client 화면에는 영향이 없다.
