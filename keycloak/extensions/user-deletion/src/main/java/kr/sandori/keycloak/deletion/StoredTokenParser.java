package kr.sandori.keycloak.deletion;

import java.io.IOException;
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
}
