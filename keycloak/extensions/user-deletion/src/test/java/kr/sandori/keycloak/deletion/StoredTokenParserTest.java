package kr.sandori.keycloak.deletion;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

import org.junit.jupiter.api.Test;

// StoredTokenParser가 저장된 토큰 JSON에서 refresh token을 제대로 꺼내는지 확인한다.
class StoredTokenParserTest {

    // Apple 토큰 응답 형태에서 refresh_token 값을 꺼낸다.
    @Test
    void readsRefreshTokenFromAppleTokenResponse() {
        String stored = """
                {"access_token":"a.b.c","token_type":"Bearer","expires_in":3600,
                 "refresh_token":"r.apple-refresh","id_token":"x.y.z"}
                """;
        assertEquals("r.apple-refresh", StoredTokenParser.refreshToken(stored));
    }

    // 저장된 토큰이 없으면 null이다.
    @Test
    void returnsNullWhenNothingStored() {
        assertNull(StoredTokenParser.refreshToken(null));
        assertNull(StoredTokenParser.refreshToken(""));
    }

    // refresh_token 항목이 없으면 null이다.
    @Test
    void returnsNullWhenRefreshTokenMissing() {
        assertNull(StoredTokenParser.refreshToken("{\"access_token\":\"a.b.c\"}"));
    }

    // JSON이 깨져 있어도 에러 대신 null이다.
    @Test
    void returnsNullForBrokenJson() {
        assertNull(StoredTokenParser.refreshToken("not-json"));
    }

    // id_token의 aud가 문자열이면 그 값이 client_id다.
    @Test
    void readsClientIdFromStringAudience() {
        String stored = storedWithIdToken(
                jwt("{\"iss\":\"https://appleid.apple.com\",\"aud\":\"kr.sandori.app\",\"sub\":\"001234.abc\"}"));
        assertEquals("kr.sandori.app", StoredTokenParser.clientId(stored));
    }

    // aud가 배열이면 첫 번째 값을 쓴다.
    @Test
    void readsFirstClientIdFromArrayAudience() {
        String stored = storedWithIdToken(jwt("{\"aud\":[\"sandori-broker\",\"other-client\"]}"));
        assertEquals("sandori-broker", StoredTokenParser.clientId(stored));
    }

    // aud나 id_token이 없으면 null이다.
    @Test
    void returnsNullClientIdWhenMissing() {
        assertNull(StoredTokenParser.clientId(storedWithIdToken(jwt("{\"sub\":\"001234.abc\"}"))));
        assertNull(StoredTokenParser.clientId(storedWithIdToken(jwt("{\"aud\":[]}"))));
        assertNull(StoredTokenParser.clientId("{\"refresh_token\":\"r.apple-refresh\"}"));
        assertNull(StoredTokenParser.clientId(null));
        assertNull(StoredTokenParser.clientId(""));
    }

    // 토큰이 깨져 있어도 에러 대신 null이다.
    @Test
    void returnsNullClientIdForBrokenToken() {
        assertNull(StoredTokenParser.clientId(storedWithIdToken("not-a-jwt")));
        assertNull(StoredTokenParser.clientId(storedWithIdToken("a.@@@.c")));
        assertNull(StoredTokenParser.clientId(storedWithIdToken(
                base64Url("{}") + "." + base64Url("not-json") + "." + base64Url("signature"))));
        assertNull(StoredTokenParser.clientId("not-json"));
    }

    // 서명은 확인하지 않으므로 가짜 서명을 붙여 JWT 모양만 만든다.
    private static String jwt(String payloadJson) {
        return base64Url("{\"alg\":\"RS256\",\"kid\":\"test\"}") + "." + base64Url(payloadJson) + "."
                + base64Url("signature");
    }

    // Apple 토큰 응답처럼 생긴 저장 토큰을 만든다.
    private static String storedWithIdToken(String idToken) {
        return "{\"access_token\":\"a.b.c\",\"refresh_token\":\"r.apple-refresh\",\"id_token\":\"" + idToken + "\"}";
    }

    private static String base64Url(String text) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(text.getBytes(StandardCharsets.UTF_8));
    }
}
