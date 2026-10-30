package kr.sandori.keycloak.deletion;

import java.util.List;


//auth-relay로 보낼 탈퇴 정보.
public record DeletionPayload(
        String eventId,
        String occurredAt,
        String realm,
        String userId,
        String email,
        List<LinkedIdentity> identities) {

    //사용자에게 연결된 외부 로그인(IdP) 하나.
    //refreshToken은 Apple이고 토큰이 저장되어 있을 때만 값이 있다.
    public record LinkedIdentity(String provider, String providerUserId, String refreshToken) {
    }
}
