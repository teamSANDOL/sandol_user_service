package kr.sandori.keycloak.deletion;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

//auth-relay로 보낼 탈퇴 정보.
public record DeletionPayload(
        String eventId,
        String occurredAt,
        String realm,
        String userId,
        String email,
        List<LinkedIdentity> identities) {

    // auth-relay와 약속한 JSON 이름(snake_case)으로 바꾼다.
    public Map<String, Object> toJsonMap() {
        Map<String, Object> json = new LinkedHashMap<>();
        json.put("event_id", eventId);
        json.put("occurred_at", occurredAt);
        json.put("realm", realm);
        json.put("user_id", userId);
        json.put("email", email);
        json.put("identities", identities.stream().map(LinkedIdentity::toJsonMap).toList());
        return json;
    }

    // 실수로 로그에 찍혀도 이메일이 드러나지 않게 한다.
    @Override
    public String toString() {
        return "DeletionPayload[eventId=" + eventId + ", realm=" + realm + ", userId=" + userId
                + ", hasEmail=" + (email != null) + ", identities=" + identities + "]";
    }

    //사용자에게 연결된 외부 로그인(IdP) 하나.
    //refreshToken은 Apple이고 토큰이 저장되어 있을 때만 값이 있다.
    public record LinkedIdentity(String provider, String providerUserId, String refreshToken) {

        public Map<String, Object> toJsonMap() {
            Map<String, Object> json = new LinkedHashMap<>();
            json.put("provider", provider);
            json.put("provider_user_id", providerUserId);
            json.put("refresh_token", refreshToken);
            return json;
        }

        // 실수로 로그에 찍혀도 토큰 값이 드러나지 않게 한다.
        @Override
        public String toString() {
            return "LinkedIdentity[provider=" + provider + ", hasRefreshToken=" + (refreshToken != null) + "]";
        }
    }
}
