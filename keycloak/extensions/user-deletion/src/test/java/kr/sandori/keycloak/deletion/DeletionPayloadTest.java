package kr.sandori.keycloak.deletion;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.Test;

// auth-relay와 약속한 JSON 모양과, 로그에 비밀이 새지 않는지 확인한다.
class DeletionPayloadTest {

    private static final DeletionPayload PAYLOAD = new DeletionPayload(
            "event-1", "2026-10-30T00:00:00Z", "Sandori", "user-1", "user@example.com",
            List.of(new DeletionPayload.LinkedIdentity("apple", "001234.apple", "r.secret-refresh"),
                    new DeletionPayload.LinkedIdentity("kakao", "987654321", null)));

    // 필드 이름이 snake_case로 바뀐다.
    @Test
    void convertsToSnakeCaseJson() {
        Map<String, Object> json = PAYLOAD.toJsonMap();

        assertEquals(List.of("event_id", "occurred_at", "realm", "user_id", "email", "identities"),
                List.copyOf(json.keySet()));
        assertEquals("user-1", json.get("user_id"));

        List<?> identities = (List<?>) json.get("identities");
        Map<?, ?> apple = (Map<?, ?>) identities.get(0);
        Map<?, ?> kakao = (Map<?, ?>) identities.get(1);
        assertEquals("apple", apple.get("provider"));
        assertEquals("001234.apple", apple.get("provider_user_id"));
        assertEquals("r.secret-refresh", apple.get("refresh_token"));
        assertNull(kakao.get("refresh_token"));
    }

    // toString에는 이메일과 토큰 값이 나오지 않는다.
    @Test
    void toStringHidesEmailAndToken() {
        String text = PAYLOAD.toString();

        assertFalse(text.contains("user@example.com"));
        assertFalse(text.contains("r.secret-refresh"));
    }
}
