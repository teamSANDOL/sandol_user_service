package kr.sandori.keycloak.deletion;

import java.io.IOException;
import java.util.Base64;
import java.util.List;
import java.util.Map;

import org.keycloak.util.JsonSerialization;

/**
 * Keycloak이 IdP 연동에 저장해 둔 토큰(JSON 문자열)에서 값을 꺼낸다.
 * IdP 설정에서 Store tokens가 켜져 있으면 IdP의 토큰 응답이 그대로 저장된다.
 */
public final class StoredTokenParser {

    private StoredTokenParser() {
    }

    //refresh_token 값을 돌려준다. 없거나 읽을 수 없으면 null.
    public static String refreshToken(String storedToken) {
        if (storedToken == null || storedToken.isBlank()) {
            return null;
        }
        try {
            Map<?, ?> json = JsonSerialization.readValue(storedToken, Map.class);
            if (json != null && json.get("refresh_token") instanceof String token && !token.isBlank()) {
                return token;
            }
            return null;
        } catch (IOException e) {
            return null;
        }
    }

    // 저장된 토큰의 id_token에서 aud(= 토큰을 발급받은 client_id)를 꺼낸다. 없거나 읽을 수 없으면 null.
    // aud가 배열이면 첫 번째 값을 쓴다. 서명은 확인하지 않는다(로그인 때 Keycloak이 이미 확인했다).
    public static String clientId(String storedToken) {
        if (storedToken == null || storedToken.isBlank()) {
            return null;
        }
        try {
            Map<?, ?> json = JsonSerialization.readValue(storedToken, Map.class);
            if (json == null || !(json.get("id_token") instanceof String idToken)) {
                return null;
            }
            // JWT는 "헤더.페이로드.서명" 형태이고, 페이로드는 Base64URL로 인코딩된 JSON이다.
            String[] parts = idToken.split("\\.");
            if (parts.length < 2) {
                return null;
            }
            Map<?, ?> claims = JsonSerialization.readValue(Base64.getUrlDecoder().decode(parts[1]), Map.class);
            Object aud = claims == null ? null : claims.get("aud");
            if (aud instanceof List<?> list && !list.isEmpty()) {
                aud = list.get(0);
            }
            return aud instanceof String value && !value.isBlank() ? value : null;
        } catch (IOException | IllegalArgumentException e) {
            // JSON이 깨졌거나(IOException) Base64가 깨진 경우(IllegalArgumentException)
            return null;
        }
    }
}
