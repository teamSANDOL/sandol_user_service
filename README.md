# 📌 산돌이 Repository Template  

## 📂 개요  

**산돌이 서비스의 사용자 정보 및 인증을 중앙 집중 관리하는 MSA 서비스**  

---

## 📌 프로젝트 구조  

- **(이 Repository에서 사용하는 개발 프레임워크 및 주요 기술 스택을 작성하세요.)**  
  - `keycloak`: 사용자 인증 및 권한 관리
- **(이 Repository가 담당하는 서비스의 역할을 간략히 설명하세요.)**  
  - 사용자 관리 서비스  

---

## 📌 문서  

- **(API 문서 링크를 삽입하세요.)**  
  - 예시: `[API 문서 (Swagger)](링크)`, `[API 문서 (Notion)](링크)`  
- **(이 Repository에서 제공하는 서비스 관련 문서를 추가하세요.)**  
  - 예시: `챗봇 명령어 목록`, `웹 서비스 이용 가이드`, `Webhook 사용법` 등  
- Keycloak realm 백업/복원 절차는 이 README의 `Keycloak realm 백업/복원` 섹션을 참고합니다.

---

## 📌 환경 설정  

- **모든 서비스는 Docker 기반으로 실행되므로, 로컬 환경에 별도로 의존하지 않음**  
- **환경 변수 파일 (`.env`) 필요 시, 샘플 파일 (`.env.example`) 제공**  
- **루트 `.env`의 `SERVICE_DOMAIN`은 Keycloak 컨테이너의 `KC_HOSTNAME`으로 주입됨**  
  - 변수명을 `KC_HOSTNAME`으로 두지 않은 이유는 Keycloak 전용 값으로 고정하지 않고, 같은 도메인 값을 다른 서비스에서도 재사용할 수 있게 하기 위함  
- **Docker Compose를 통해 서비스 간 네트워크 및 볼륨을 설정**  
- **프론트엔드 서비스(챗봇 서버, 웹 서비스)와 백엔드 서비스(API 서버)의 차이점을 반영하여 개별 실행 가능**  

### 📌 실행 방법  

#### 1. 기본 실행 (모든 서비스 실행)  

```bash
docker compose up -d
```

#### 2. 특정 서비스만 실행 (예: 챗봇 서버)  

```bash
docker compose up -d <서비스명>
```

#### 3. 서비스 중지  

```bash
docker compose down
```

#### 4. 환경 변수 변경 후 재시작  

```bash
docker compose up -d --build
```

---

## 📌 Keycloak realm 백업/복원

이 저장소의 Keycloak realm JSON 파일은 **Keycloak의 export 기능으로 생성한 결과물**입니다.

- realm 설정 파일: `<realm>-realm.json`
- 사용자 파일: `<realm>-users-0.json`, `<realm>-users-1.json` ...

현재 저장소에서 확인되는 예시는 다음과 같습니다.

- `keycloak-export/Sandori-realm.json`
- `keycloak-export/Sandori-users-0.json`
- `keycloak-export/master-realm.json`
- `keycloak-export/master-users-0.json`
- `backup/keycloak-export/*.json`도 같은 형식의 백업 사본으로 볼 수 있습니다.

### 생성 방법

Keycloak 공식 import/export 명령은 `kc.sh export`이며, 디렉터리 기준으로 내보내면 현재 저장소와 같은 파일 형식이 생성됩니다.

```bash
/opt/keycloak/bin/kc.sh export \
  --dir /tmp/keycloak-export \
  --users different_files \
  --users-per-file 100
```

특정 realm만 백업하려면 `--realm` 옵션을 추가합니다.

```bash
/opt/keycloak/bin/kc.sh export \
  --dir /tmp/keycloak-export \
  --realm Sandori \
  --users different_files \
  --users-per-file 100
```

생성 후 `/tmp/keycloak-export` 아래에 다음과 같은 파일이 만들어집니다.

- `Sandori-realm.json`
- `Sandori-users-0.json`
- 사용자 수가 많으면 `Sandori-users-1.json` 같은 추가 파일

운영 서버에서 백업 파일을 갱신할 때는 export 결과를 꺼내서 별도 보관용 `backup/keycloak-export/`에 관리하면 됩니다.

### 복원 방법

Keycloak은 directory import 시 다음 파일명을 기준으로 realm을 읽습니다.

- `<realm>-realm.json`
- `<realm>-users-<번호>.json`

이 저장소에는 Keycloak 백업/복원용 compose 파일이 있습니다.

- 루트 `docker-compose.auth-bak.yml`: **실제 운영 자동 백업 실행용 standalone compose 파일**
- `sandol_user_service/docker-compose.auth-bak.yml`: **값이 적용되지 않은 demo/template 파일**
- 루트 `docker-compose.auth-restore.yml`: **실제 운영 복원 실행용 standalone compose 파일**
- `sandol_user_service/docker-compose.auth-restore.yml`: **값이 적용되지 않은 demo/template 파일**

이제 백업은 **호스트 bind mount에 직접 쓰지 않고**, 컨테이너 내부 임시 경로에 export한 뒤 결과를 복사하는 방식으로 수행합니다. 따라서 서버별 파일 권한 차이 때문에 `Permission denied`가 발생하는 문제를 줄일 수 있습니다.

루트 `docker-compose.auth-bak.yml`은 `keycloak-db`와 `keycloak`을 함께 포함하고 있어서, 실행 시 DB를 띄운 뒤 Keycloak이 자동으로 realm export를 수행하고 종료합니다.

```yaml
services:
  keycloak-db:
    image: postgres:16-alpine
    volumes:
      - keycloak_db_data:/var/lib/postgresql/data

  keycloak:
    command:
      [
        "export",
        "--dir",
        "/tmp/keycloak-export",
        "--realm",
        "Sandori",
        "--users",
        "different_files",
        "--users-per-file",
        "100"
      ]
    restart: "no"
    depends_on:
      keycloak-db:
        condition: service_healthy
```

`sandol_user_service/docker-compose.auth-bak.yml`은 다음처럼 placeholder 기반으로 남겨두고, 실제 운영에는 루트 `docker-compose.auth-bak.yml`에 필요한 값을 반영해서 사용합니다.

```yaml
services:
  keycloak-db:
    image: postgres:16-alpine

  keycloak:
    command:
      [
        "export",
        "--dir",
        "/tmp/keycloak-export",
        "--realm",
        "YOUR_REALM_NAME",
        "--users",
        "different_files",
        "--users-per-file",
        "100"
      ]
```

루트 `docker-compose.auth-restore.yml`은 `keycloak-db`와 `keycloak`을 함께 포함하고 있고, `keycloak`은 `/tmp/keycloak-import`를 대상으로 import를 수행하도록 구성합니다.

```yaml
services:
  keycloak-db:
    image: postgres:16-alpine

  keycloak:
    command:
      [
        "import",
        "--dir",
        "/tmp/keycloak-import",
        "--override",
        "true"
      ]
    depends_on:
      keycloak-db:
        condition: service_healthy
```

오프라인 import 명령 자체의 일반 예시는 다음과 같습니다.

```bash
/opt/keycloak/bin/kc.sh import --dir /opt/keycloak/data/import
```

이 README에서 설명하는 **standalone 복원 compose 흐름**은 위 일반 예시와 별개로, 컨테이너 내부 `/tmp/keycloak-import` 경로를 사용합니다.

### docker-compose.yml로 실행 중인 서버 반영 절차

루트 `docker-compose.yml`과 `docker-compose.dev.yml`의 Keycloak 서비스는 현재 다음 특징을 가집니다.

- `command: ["start"]`
- `keycloak_db_data:/var/lib/postgresql/data` 볼륨과 연결된 `keycloak-db` 사용
- `./sandol_user_service/web/keycloak-theme:/opt/keycloak/themes:ro` 마운트 사용
- **백업 전용 `keycloak-db` + export command는 `docker-compose.auth-bak.yml`에서만 추가됨**
- **`--import-realm` 옵션 없음**

즉, `docker-compose.yml`로 이미 실행 중인 서버는 백업 디렉터리만 준비한다고 자동으로 realm 백업이 생성되지는 않습니다.

운영 중인 서버에서 realm 백업을 생성하려면 다음 순서로 작업합니다.

1. 기존 운영 Keycloak과 같은 DB를 바라보도록 루트 `.env` 값(`KC_DB_USERNAME`, `KC_DB_PASSWORD` 등)을 확인합니다.
2. 백업 결과를 받을 루트 `backup/keycloak-export/` 디렉터리를 준비합니다.
3. 운영 중인 Keycloak **및 keycloak-db 서비스**를 먼저 중지합니다. 백업용 compose도 같은 DB 볼륨을 사용하기 때문입니다.

```bash
docker compose stop keycloak keycloak-db
```

4. 루트 `docker-compose.auth-bak.yml`을 **단독으로 실행**합니다.

```bash
docker compose -f docker-compose.auth-bak.yml up --abort-on-container-exit --exit-code-from keycloak
```

이 명령을 실행하면 `keycloak-db`가 먼저 올라오고, 이어서 `keycloak`의 export command가 자동으로 실행된 뒤 결과가 **컨테이너 내부의** `/tmp/keycloak-export`에 생성됩니다.

5. export가 성공적으로 끝난 것을 확인한 뒤, 이전 백업 조각이 남지 않도록 대상 디렉터리를 비우고 결과를 호스트로 복사합니다.

```bash
mkdir -p backup/keycloak-export
rm -f backup/keycloak-export/*.json
docker compose -f docker-compose.auth-bak.yml cp keycloak:/tmp/keycloak-export/. ./backup/keycloak-export
```

6. 백업 컨테이너를 정리합니다.

```bash
docker compose -f docker-compose.auth-bak.yml down
```

7. 작업이 끝나면 운영용 compose로 `keycloak-db`와 `keycloak` 서비스를 다시 기동합니다.

```bash
docker compose up -d keycloak-db keycloak
```

8. 기동 후 `/auth/health/live` 및 Keycloak 관리자 콘솔에서 서비스가 정상 복구되었는지 확인하고, `backup/keycloak-export/` 아래에 `Sandori-realm.json`, `Sandori-users-0.json` 등이 생성되었는지 확인합니다.

### backup/keycloak-export 결과 파일 꺼내기

백업 파일이 서버의 `backup/keycloak-export/`에 생성된 뒤에는, 필요에 따라 운영 서버 밖으로 복사해 별도 보관할 수 있습니다.

서버 안에서 먼저 압축 파일을 만들려면:

```bash
tar -czf keycloak-export-backup.tar.gz -C backup keycloak-export
```

그 다음 로컬 PC에서 서버로부터 직접 내려받으려면:

```bash
scp root@<server-host>:~/tuk_sandol_team/keycloak-export-backup.tar.gz .
```

압축 없이 디렉터리째 바로 내려받으려면:

```bash
scp -r root@<server-host>:~/tuk_sandol_team/backup/keycloak-export ./keycloak-export
```

다운로드한 뒤에는 로컬 보관소나 다른 백업 스토리지로 옮기기 전에 파일 목록을 확인합니다.

```bash
ls -l ./keycloak-export
```

### 복원 절차

복원은 백업과 반대로, **호스트의 JSON 파일을 먼저 복원 컨테이너 내부로 복사한 다음** `kc.sh import`를 실행하는 방식으로 수행합니다.

1. 복원할 JSON 파일이 루트 `backup/keycloak-export/` 아래에 있는지 확인합니다.
2. 운영 중인 Keycloak **및 keycloak-db 서비스**를 먼저 중지합니다.

```bash
docker compose stop keycloak keycloak-db
```

3. 복원용 compose에서 DB만 먼저 실행합니다.

```bash
docker compose -f docker-compose.auth-restore.yml up -d keycloak-db
```

4. `keycloak-db`가 `healthy` 상태가 되었는지 확인합니다.

```bash
docker compose -f docker-compose.auth-restore.yml ps
```

`STATUS`에 `healthy`가 보일 때까지 기다린 뒤 다음 단계로 진행합니다.

5. import 컨테이너를 생성만 해둡니다.

```bash
docker compose -f docker-compose.auth-restore.yml create keycloak
```

6. 복원할 JSON 파일을 컨테이너 내부 `/tmp/keycloak-import`로 복사합니다.

```bash
docker compose -f docker-compose.auth-restore.yml cp ./backup/keycloak-export/. keycloak:/tmp/keycloak-import
```

7. import 컨테이너를 실행합니다.

```bash
docker compose -f docker-compose.auth-restore.yml start keycloak
docker compose -f docker-compose.auth-restore.yml logs -f keycloak
```

8. import가 끝나면 복원 컨테이너를 정리합니다.

```bash
docker compose -f docker-compose.auth-restore.yml down
```

9. 운영용 compose로 `keycloak-db`와 `keycloak` 서비스를 다시 기동합니다.

```bash
docker compose up -d keycloak-db keycloak
```

10. 기동 후 `/auth/health/live` 및 Keycloak 관리자 콘솔에서 realm/client/user 정보가 정상 복원되었는지 확인합니다.

정리하면, **루트 `docker-compose.yml`은 평상시 운영용 구성**이고, **자동 백업은 루트 `docker-compose.auth-bak.yml`을 단독 실행해서 수행**합니다.

### 주의사항

- Keycloak 공식 문서 기준으로 `export`/`import`는 **서버가 실행 중이 아닐 때** 수행하는 것이 안전합니다.
- 루트 `docker-compose.auth-bak.yml`은 **standalone 백업 전용 compose 파일**입니다.
- 루트 `docker-compose.auth-restore.yml`은 **standalone 복원 전용 compose 파일**입니다.
- `sandol_user_service/docker-compose.auth-bak.yml`은 demo/template 파일이므로, 그대로 운영에 사용하지 말고 루트 `docker-compose.auth-bak.yml`에 필요한 값을 반영할 때 참고용으로만 사용합니다.
- `sandol_user_service/docker-compose.auth-restore.yml`도 demo/template 파일이므로, 그대로 운영에 사용하지 말고 루트 `docker-compose.auth-restore.yml`에 필요한 값을 반영할 때 참고용으로만 사용합니다.
- 루트 `docker-compose.auth-bak.yml`은 export 전용 command를 사용하므로, 이 파일을 실행하면 Keycloak 서버가 평소처럼 계속 떠 있는 것이 아니라 **백업 수행 후 종료**됩니다.
- 루트 `docker-compose.auth-restore.yml`은 import 전용 command를 사용하므로, 복원할 JSON 파일을 먼저 `docker compose cp`로 컨테이너 내부 `/tmp/keycloak-import`에 넣어야 합니다.
- 루트 `docker-compose.auth-bak.yml`은 운영용 `keycloak-db`와 같은 DB 볼륨(`keycloak_db_data`)을 사용하므로, 메인 `keycloak-db`가 살아 있는 상태에서 동시에 실행하면 안 됩니다.
- 루트 `docker-compose.auth-restore.yml`도 같은 DB 볼륨(`keycloak_db_data`)을 사용하므로, 메인 `keycloak-db`가 살아 있는 상태에서 동시에 실행하면 안 됩니다.
- 루트 `.env`의 `COMPOSE_PROJECT_NAME`이 운영 compose와 동일해야 같은 `keycloak_db_data` 볼륨을 바라봅니다. 다른 프로젝트 이름으로 실행하면 운영 데이터가 아닌 다른 볼륨을 보게 될 수 있습니다.
- 백업 결과는 bind mount가 아니라 컨테이너 내부 `/tmp/keycloak-export`에 먼저 만들어지고, 이후 `docker compose cp`로 호스트 `backup/keycloak-export/`에 복사합니다.
- `docker compose -f docker-compose.auth-bak.yml up ...`가 실패하면 `docker compose cp`는 실행하지 말고, 먼저 로그와 종료 코드를 확인해야 합니다.
- `docker compose -f docker-compose.auth-restore.yml cp ...`가 실패하면 import를 시작하지 말고, 컨테이너 생성 상태와 복사 대상 경로를 먼저 확인해야 합니다.
- 현재 운영 Keycloak 실행 명령에는 `--import-realm`이 없으므로, **운영 compose를 다시 올린다고 자동 import는 실행되지 않습니다.** 시작 시 자동 import가 필요하면 Keycloak 실행 명령에 `start --import-realm` 형태가 추가되어야 합니다.
- 루트 `docker-compose.yml`과 `docker-compose.dev.yml`만으로는 export 결과 복사 단계가 없으므로, 운영 중 서버에서 compose만 띄운다고 백업 파일이 자동 저장되지는 않습니다.
- `sandol_user_service/base_data/Sandori-realm.json` 및 `Sandori-realm.noauthz.json`은 서비스 내부 기준 데이터로 볼 수 있지만, 실제 백업/복원 작업 경로는 루트 `backup/keycloak-export/`입니다.

---

## 📌 회원 탈퇴 확장

`keycloak/extensions/user-deletion`은 Keycloak 계정이 삭제되기 직전에 연동 정보(IdP 종류, Apple refresh token과 client_id, 이메일)를 모아 암호화한 뒤 auth-relay로 보내는 Keycloak 확장입니다. Apple 토큰 폐기, 카카오 연결 해제, 재시도, 실패 메일은 auth-relay가 담당합니다.

- 대상 realm(기본 `Sandori`)의 사용자만 처리하며, master의 관리자 계정은 처리하지 않습니다.
- auth-relay가 `202`로 응답해야 삭제가 진행됩니다. 연결 실패, 시간 초과, `202` 외 응답이면 **삭제를 취소**하고 계정을 그대로 둡니다.
- 관리자 API(`DELETE /admin/realms/{realm}/users/{id}`)로 삭제하다 막히면 `503` `{"error":"account_deletion_unavailable"}`을 돌려줍니다. 사용자가 탈퇴 화면에서 탈퇴하다 막힌 경우에는 이 응답을 받지 않습니다.

### 설정

`docker-compose.yml`의 `keycloak` 서비스가 `.env`에서 아래 값을 받습니다.

| 환경 변수 | 기본값 | 설명 |
| --- | --- | --- |
| `SANDOL_DELETION_RELAY_URL` | (없음) | auth-relay 수신 주소 (예: `http://auth-relay:8000/relay/internal/account-deletions`) |
| `SANDOL_DELETION_KEY` | (없음) | AES-256 키(32바이트를 Base64로 적은 값). auth-relay와 같은 값 |
| `SANDOL_DELETION_KEY_ID` | `v1` | 키 식별자 |

- `SANDOL_DELETION_RELAY_URL`이 비어 있으면 auth-relay로 보내지 않고 경고 로그만 남긴 채 삭제를 허용합니다. **운영에서는 반드시 설정해야 합니다.**
- 값이 잘못되어 있으면(예: 키가 32바이트가 아님) 시작할 때 ERROR 로그를 남기고, 고칠 때까지 대상 realm의 삭제를 모두 막습니다.
- 대상 realm(`SANDOL_DELETION_REALMS`, 기본 `Sandori`)과 대기 시간(`SANDOL_DELETION_TIMEOUT_SECONDS`, 기본 `5`)은 바꿔야 할 때만 compose에 추가합니다.

키 생성:

```bash
openssl rand -base64 32
```

### Keycloak 탈퇴 기능 켜기

사용자가 직접 탈퇴하는 Keycloak 내장 화면(Delete Account)은 기본으로 꺼져 있고, `base_data`의 realm에도 꺼져 있습니다. 관리자 콘솔의 대상 realm에서 아래 두 가지를 모두 켜야 쓸 수 있습니다.

1. Authentication → Required actions → `Delete Account`를 Enabled로 바꿉니다.
2. Realm settings → User registration → Default roles에 `account` 클라이언트의 `delete-account` 역할을 추가합니다. 기본 역할 묶음(`default-roles-sandori`)에 들어가므로 기존 사용자에게도 적용됩니다.

### 탈퇴 화면 열기와 결과

로그인할 때와 같은 인가 요청(`{issuer}/protocol/openid-connect/auth`, PKCE 포함)에 `kc_action=delete_account` 파라미터만 더해서 엽니다.

- 이미 로그인되어 있어도 항상 다시 인증합니다(비밀번호 또는 연동된 IdP 버튼).
- Apple로 다시 인증하면 그때 Apple 토큰이 저장되므로(Store tokens가 켜져 있을 때), 전에 Apple로 로그인한 적이 없어도 refresh token과 client_id가 전달됩니다.
- 취소하면 `redirect_uri?kc_action=delete_account&kc_action_status=cancelled&code=…`로 돌아옵니다. 계정은 그대로이고 이 확장도 실행되지 않습니다.
- 탈퇴에 성공하면 Keycloak 완료 화면이 나옵니다. 앱으로 자동으로 돌아가지 않으며, "서비스로 돌아가기" 버튼은 클라이언트의 Base URL로 이동합니다.
- auth-relay 문제로 막히면 계정은 그대로 남습니다.
- 성공 결과가 redirect로 오지 않으므로, 앱은 화면이 닫힌 뒤 토큰 갱신을 시도해서 계정이 남아 있는지 확인해야 합니다. 삭제된 사용자는 세션이 없어져 갱신이 거부됩니다.
- Keycloak에는 사용자가 자기 계정을 지우는 REST API가 없습니다(`DELETE {issuer}/account`는 26.3.2와 26.8.1 모두 405). 사용자 탈퇴는 이 화면으로만 합니다.

### 빌드와 반영

```bash
cd keycloak/extensions/user-deletion
./gradlew build   # JDK 21 필요, 테스트 포함
cp build/libs/sandol-user-deletion-*.jar ../../providers/
```

- 빌드한 jar는 Apple 확장 jar처럼 `keycloak/providers/`에 커밋합니다. 코드를 고치면 다시 빌드해서 jar도 함께 교체해야 합니다.
- Keycloak을 재시작한 뒤 로그에서 설정 상태를 확인합니다.

```bash
docker compose restart keycloak
docker compose logs keycloak | grep sandol-user-deletion
```

- `relay enabled: url=…`가 나오면 auth-relay로 보내는 상태입니다.
- `SANDOL_DELETION_RELAY_URL is not set` 경고가 나오면 주소가 비어 있는 상태입니다. 로컬에서는 정상이며, auth-relay로 보내지 않고 삭제를 허용합니다.
- `invalid configuration: …` ERROR가 나오면 값이 잘못된 상태입니다. 고칠 때까지 대상 realm의 삭제가 모두 막힙니다.
- 테스트 사용자를 삭제하면 `collected: realm=…, userId=…, hasEmail=…, identities=[…]` 로그가 남습니다. 이어서 보냈으면 `sent to auth-relay`, 주소가 비어 있으면 `relay disabled` 경고가 남습니다.

### 탈퇴 실패 로그

탈퇴를 막으면 ERROR 로그 한 줄을 남깁니다. 토큰, 이메일, 키는 로그에 남기지 않습니다.

```text
[sandol-user-deletion] DELETION_BLOCKED realm=Sandori userId=… eventId=… reason=RELAY_REJECTED providers=apple,kakao status=500
```

- `providers`는 연동된 IdP 목록입니다. 연동이 없으면 `none`, 정보를 모으기 전에 실패하면 `-`입니다.
- `status`는 `RELAY_REJECTED`일 때만 붙습니다.

`reason` 값:

- `RELAY_UNREACHABLE`: auth-relay에 연결하지 못했습니다(꺼짐, 주소 오류, 다른 Docker 네트워크).
- `RELAY_TIMEOUT`: 대기 시간(기본 5초) 안에 응답이 없었습니다. auth-relay가 받아서 저장했는데 탈퇴만 막혔을 수 있으므로, auth-relay는 같은 사용자의 요청을 중복 처리할 수 있어야 합니다.
- `RELAY_REJECTED`: auth-relay가 `202` 외의 상태 코드로 응답했습니다. 키가 서로 다르면 auth-relay가 복호화하지 못해 이 사유가 됩니다.
- `CONFIG_INVALID`: `SANDOL_DELETION_*` 값이 잘못되었습니다. 원인은 Keycloak 시작 로그의 `invalid configuration: …` 줄에 있습니다.
- `INTERNAL_ERROR`: 그 밖의 예상하지 못한 오류입니다. 이 사유만 스택 트레이스를 함께 남깁니다.

Apple 연동 사용자인데 저장된 Apple 토큰이 없으면 `Apple refresh token or client_id not found for userId=…` 경고를 남깁니다. 탈퇴는 진행되지만 auth-relay가 Apple 토큰을 폐기할 수 없으므로, Apple IdP의 Store tokens가 켜져 있는지 확인합니다.

### 운영 반영 체크리스트

- [ ] `.env`에 `SANDOL_DELETION_RELAY_URL`, `SANDOL_DELETION_KEY` 설정 (auth-relay와 같은 키)
- [ ] Keycloak과 auth-relay가 같은 Docker 네트워크에 있는지 확인
- [ ] Apple IdP의 **Store tokens** 켜기 (꺼져 있으면 Apple refresh token을 보낼 수 없음)
- [ ] `Delete Account` 켜기와 `delete-account` 기본 역할 추가 (위 "Keycloak 탈퇴 기능 켜기")
- [ ] 로그에서 `[sandol-user-deletion] relay enabled` 확인

---

## 📌 배포 가이드  

- **(CI/CD 적용 여부 및 배포 자동화 여부를 설명하세요.)**  
  - 예시: `GitHub Actions 사용 여부`, `GCP Cloud Run 자동 배포`, `AWS Lambda 연동 여부` 등  
- **(배포 시 관리해야 할 환경 변수 및 보안 설정을 명시하세요.)**  
  - 예시: `.env 파일의 API Key`, `Webhook URL`, `DB 접속 정보` 등
- **(배포시 주의해야할 사항을 설명하세요.)**
  - 예시: `별도 domain 연결 필요`, `독립 Database 설정 필요` 등

---

## 📌 문의  

- **(디스코드 채널 링크를 삽입하세요)**

---
🚀 **산돌이 프로젝트와 함께 효율적인 개발 환경을 만들어갑시다!**  
