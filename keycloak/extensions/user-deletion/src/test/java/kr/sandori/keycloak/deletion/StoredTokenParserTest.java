package kr.sandori.keycloak.deletion;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

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
}
