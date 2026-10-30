package kr.sandori.keycloak.deletion;

import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

import org.keycloak.models.FederatedIdentityModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;

// 삭제되는 사용자에게서 auth-relay로 보낼 정보를 모은다.
public class DeletionPayloadCollector {

    static final String APPLE = "apple";

    public DeletionPayload collect(UserModel.UserPreRemovedEvent event) {
        KeycloakSession session = event.getKeycloakSession();
        RealmModel realm = event.getRealm();
        UserModel user = event.getUser();

        // 사용자에게 연결된 IdP 목록을 LinkedIdentity 목록으로 바꾼다.
        List<DeletionPayload.LinkedIdentity> identities = session.users()
                .getFederatedIdentitiesStream(realm, user)
                .map(DeletionPayloadCollector::toLinkedIdentity)
                .toList();

        return new DeletionPayload(
                UUID.randomUUID().toString(),
                Instant.now().toString(),
                realm.getName(),
                user.getId(),
                user.getEmail(),
                identities);
    }

    // IdP 연동 하나를 변환한다. Apple이면 저장된 토큰에서 refresh token을 꺼낸다.
    private static DeletionPayload.LinkedIdentity toLinkedIdentity(FederatedIdentityModel link) {
        String provider = link.getIdentityProvider().toLowerCase(Locale.ROOT);
        String refreshToken = APPLE.equals(provider)
                ? StoredTokenParser.refreshToken(link.getToken())
                : null;
        return new DeletionPayload.LinkedIdentity(provider, link.getUserId(), refreshToken);
    }
}
